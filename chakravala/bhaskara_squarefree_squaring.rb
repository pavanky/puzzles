#!/usr/bin/env ruby

require 'prime'

def gcdext(x, y)
  if x < 0
    g, a, b = gcdext(-x, y)
    return [g, -a, b]
  end
  if y < 0
    g, a, b = gcdext(x, -y)
    return [g, a, -b]
  end
  r0, r1 = x, y
  a0 = b1 = 1
  a1 = b0 = 0
  until r1.zero?
    q = r0 / r1
    r0, r1 = r1, r0 - q*r1
    a0, a1 = a1, a0 - q*a1
    b0, b1 = b1, b0 - q*b1
  end
  [r0, a0, b0]
end
  
def invert(num, mod)
  g, a, b = gcdext(num, mod)
  unless g == 1
    raise ZeroDivisionError.new("#{num} has no inverse modulo #{mod}")
  end
  a % mod
end
  
class Pell
  attr_accessor :x, :y, :d

  def initialize(x, y, d)
    @x = x
    @y = y
    @d = d
  end

  def *(other)
    return Pell.new(@x*other.y+@y*other.x,
                    @d*@x*other.x+@y*other.y,
                    @d)
  end
  
  def **(n)
    p = Pell.new(0,1,@d)
    f = self
    m = n

    while m >= 1
        if (m%2)==1
          p = p*f
        end
        m = (m/2).floor
        f = f*f
    end
    return p
  end

end

def squarefree_part(x)
  sf = 1
  factors = x.prime_division
  for f in factors
    if (f[1] % 2==1)
      sf = sf*f[0]
    end
  end
  return(sf)
end

# Solving y^2 - D*x^2 = 1

# Archimedes cattle problem
# Removing factor 2^2*4657^2

#a = 609*7766*2**2*4657**2
arg = eval(ARGV[0])

# Squarefree part
d = squarefree_part(arg)

# Square part
s = arg/d

sd = Integer.sqrt(d)

x_init = 1
y_init = sd
h_init = d*x_init**2 - y_init**2

i = (-y_init % h_init)*(invert(x_init,h_init) % h_init) % h_init
m_init = h_init*(sd/h_init).floor+i

if (m_init>sd)
  m_init += -h_init
end

steps = 0

x = x_init
y = y_init
h = h_init
m = m_init

print
print("[h, m] = [#{h}, #{m}]\n")

while not([1,2,4].include?(h))

  #print("[x, y, h, m] = [#{x}, #{y}, #{h}, #{m}]\n")

  x = (m_init*x_init+y_init)/h_init
  y = (d*x_init+m_init*y_init)/h_init

  h = (d-m_init**2)/h_init

  #print("[x, y, h, m] = [#{x}, #{y}, #{h}, #{m}]\n")

  i = ((-y % h)*(invert(x,h) % h) % h)
  m = h*(sd/h).floor+i

  #print("[x, y, h, m] = [#{x}, #{y}, #{h}, #{m}]\n")

  if (m>sd)
    m += -h
  end

  #print("[x, y, h, m] = [#{x}, #{y}, #{h}, #{m}]\n")

  x_init = x
  y_init = y
  h_init = h
  m_init = m
  steps = steps+1

  print("[h, m] = [#{h}, #{m}]\n")
end

print("\n")
print("h = #{h}\n")

if h==1 && (steps % 2)==0

  x, y = 2*x*y, d*x**2+y**2
  
elsif h==2
  
  x, y = 2*x*y, d*x**2+y**2
  x, y = x/2, y/2
  
elsif h==4
  
  a, b = Rational(x,2), Rational(y,2)
  
  if a.is_a?(Integer) && b.is_a?(Integer)
    
    x, y = a.to_i, b.to_i
    
  else

    a_1, b_1 = 2*a*b, d*a**2+b**2
    
    if a_1.is_a?(Integer) && b_1.is_a?(Integer)
      x, y = a_1.to_i, b_1.to_i
    else
      
      x, y = a*b_1+a_1*b, b*b_1+d*a*a_1
      if (steps % 2)==0
        x, y = 2*x*y, d*x**2+y**2
      end
      x, y = x.to_i, y.to_i
      
    end
    
  end
end

v = y**2-d*x**2
print("\n")
print("squarefree equation: #{d}*x^2 + 1 = y^2\n")
print("squarefree solution = [#{x}, #{y}, #{v}]\n")
print("steps = #{steps}\n")

# Find power for each p^k factor, take LCM

e = 1

if (s>1)

  rs = Integer.sqrt(s)
  rs_f = rs.prime_division

  powers = []

  a = Pell.new(x, y, d)
    
  for factor in rs_f
    i = 1
    m = factor[0]**factor[1]
        
    b = Pell.new(a.x % m, a.y % m, a.d)
    r = b.x
        
    c = b
        
    while not(r==0)
      c = c*b
      r = c.x % m
      i += 1
    end
    powers.append(i)
  end

  e = powers.reduce(1, :lcm)
  b = a**e
  x, y = (b.x/rs).floor, b.y
end

v = y**2-arg*x**2
print("\n")
print("full equation: #{arg}*x^2 + 1 = y^2\n")
print("full solution = [#{x}, #{y}, #{v}]\n")
print("power = #{e}\n")
print("#{Math.log(x, 10).floor+1}, #{Math.log(y, 10).floor+1}\n")
print("#{x.to_s.length}, #{y.to_s.length}\n")
