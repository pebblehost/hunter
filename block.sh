# A very very basic script that was throw together in 5 minutes to apply this IP blocklist to the DOCKER-USER chain.
# Combine with a cron every few hours, it'll automatically add and remove IPs based on this list.

# Caution is advised when using this if you've manually changed or setup new iptables rules regarding docker, as this will probably remove them
rules=`/usr/sbin/iptables -w 2 -n -L DOCKER-USER | tail -n +3 | grep "DROP" | grep "all"`
IFS=$'\n'
blocked_ips=`curl -s "https://raw.githubusercontent.com/pebblehost/hunter/master/ips.txt"`
for ip in $blocked_ips; do
    if [[ `echo "$rules" | grep "$ip"` == "" ]]; then
        echo "Applying block to $ip"
        /usr/sbin/iptables -w 2 -I DOCKER-USER -s $ip/32 -j DROP
    fi
done

for rule in $rules; do
    blocked_ip=`echo "$rule" | awk {'print $4'}`
    if [[ `echo "$blocked_ips" | grep "$blocked_ip"` == "" ]]; then
        echo "Removing block from $blocked_ip"
        /usr/sbin/iptables -w 2 -D DOCKER-USER -s $blocked_ip/32 -j DROP
    fi
done
unset IFS

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION 
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
