--Alchemage Laboratory
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cid=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cid
end
local id,cid=getID()
function cid.initial_effect(c)
	c:EnableCounterPermit(0x1818)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(cid.atg)
	e3:SetValue(cid.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	--place from Deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(cid.tftg)
	e2:SetOperation(cid.tfop)
	c:RegisterEffect(e2)
	--Destroy replace
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTarget(cid.desreptg)
	e5:SetOperation(cid.desrepop)
	c:RegisterEffect(e5)
	--Add counter2
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e6:SetCode(EVENT_LEAVE_FIELD_P)
	e6:SetRange(LOCATION_FZONE)
	e6:SetOperation(cid.addop2)
	c:RegisterEffect(e6)
	--Distribute counters
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,1))
	e7:SetCategory(CATEGORY_COUNTER)
	e7:SetType(EFFECT_TYPE_IGNITION)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCountLimit(1)
	e7:SetCost(cid.ccost)
	e7:SetOperation(cid.ccop)
	c:RegisterEffect(e7)
end
--Filters
function cid.tffilter(c,tp)
	return c:IsType((TYPE_SPELL+TYPE_TRAP) and (TYPE_CONTINUOUS))and c:IsSetCard(0x8108) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
--ATK boost
function cid.atkval(e,c)
	return e:GetHandler():GetCounter(0x1818)*50
end
function cid.atg(e,c)
	return c:IsType(TYPE_TOKEN)
end
--Place from Deck
function cid.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(cid.tffilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function cid.tfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.tffilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			tc:AddCounter(0x1818,5)
		end
	end
end
--Destroy Replace
function cid.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE)
		and e:GetHandler():GetCounter(0x1818)>0 end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function cid.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveCounter(ep,0x1818,1,REASON_EFFECT)
end
--Recover Mana
function cid.addop2(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	local c=eg:GetFirst()
	while c~=nil do
		if c~=e:GetHandler() and c:IsLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
			count=count+c:GetCounter(0x1818)
		end
		c=eg:GetNext()
	end
	if count>0 then
		e:GetHandler():AddCounter(0x1818,count)
	end
end
--Distribute Mana
function cid.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1818,1,REASON_COST) end
	local ct={}
	local countmax=e:GetHandler():GetCounter(0x1818)
	for i=countmax,1,-1 do
		if e:GetHandler():IsCanRemoveCounter(tp,0x1818,i,REASON_COST)  then
			table.insert(ct,i)
		end
	end
	if #ct==1 then 
		e:GetHandler():RemoveCounter(tp,0x1818,1,REASON_COST)
		e:SetLabel(1)
	else
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		e:GetHandler():RemoveCounter(tp,0x1818,ac,REASON_COST)
		e:SetLabel(ac)
	end
end
function cid.ccop(e,tp,eg,ep,ev,re,r,rp)
	local count=e:GetLabel()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if g:GetCount()==0 then return end
	while count>0 do
		local ct={}
		for i=count,1,-1 do
			table.insert(ct,i)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
		local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x1818,ac)
		count=count-ac
	end
end
