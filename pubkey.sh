#!/bin/sh
principal=nero
pubkey="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPd5qXV3vofw5s7rCk12TBrjHKHPw2r8csX4/PCA/j4A/fM+qZJTyAhOjcFWHA47GhpbZ4RcVsRkj+gDlaYzllzTpovUiUhR2vmNwSx9h/tql4qpMQXFQXQiQKQxCnL5V3poeId1AaZYkb0m+Ld0QQYV23xX3RZwfGXBu2K9GwYlLVEnVSp7+1uvfFbGdAPn/p50PX3yCsctIbzO9aF781hjMEUAuELq+oztZvpCPvN3nyzExq9LH8fjzhwJsHpl+65bsEATIFoixJmo6WgiKMNwEweuUpZ95ZzkctkpiiCgIb+vlhtMRw09HDszaASGgh6/6OMTD1Q1p3KoA4SLHXA53NpTsYZ1+tu7tCs4NptBBVXSH5YSqRrgY0LgZZfBOpPk3cVyndxvR63d0ZdYSPK5Or7QrPkiZbyci1jt1/TFlQEXE0k3VhuvKSYtCJW8BhT7PdWqfUY6sgE9TR8g+rwN7BlFNiEG4oA9DhQbQZ/lkcZhm/HYatQqJt5Nwk1QwfvdkYUaZo+kptA00z+6i7oKD0fAwFqNxMp15l0TYYtDQ+LQ6XbqyqUmo+qgktABZ2RMg3PXhh5bhu1mDBw5C3jRl83jAj1OSL8ys/JzidpTjegPdFQpWyyG9trp+w5qoLbtWzuu1O/itGw/baGwvOhjqREnXTJ1kX7vSwh1MAFQ== SSH CA"

id=$(printf '%s\n' "$pubkey"|awk '{print($2)}')
line=$(printf  'cert-authority,principals="%s" %s\n' "nero" "$pubkey")
file="$HOME"/.ssh/authorized_keys

mkdir -p "${file%/*}"
if ! grep -q "$id" "$file"; then
  printf '%s\n' "$line" >> "$file"
fi
