--Volcanic Kiln Octopus
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	c:EnableCounterPermit(0xb9a)
	c:SetCounterLimit(0xb9a,10)
	c:EnableReviveLimit()
	--change name
	local stmt0=Effect.CreateEffect(c)
	stmt0:SetType(EFFECT_TYPE_SINGLE)
	stmt0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	stmt0:SetCode(EFFECT_ADD_CODE)
	stmt0:SetRange(LOCATION_ONFIELD)
	stmt0:SetValue(69537999)
	c:RegisterEffect(stmt0)
	--spsummon rule
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(cid.sprcon)
	e2:SetOperation(cid.sprop)
	c:RegisterEffect(e2)
	--add counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,id)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(cid.ctcost)
	e3:SetTarget(cid.cttg)
	e3:SetOperation(cid.ctop)
	c:RegisterEffect(e3)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCountLimit(1,id+100)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(cid.ctcost2)
	e4:SetTarget(cid.cttg2)
	e4:SetOperation(cid.ctop2)
	c:RegisterEffect(e4)
end
--SPSUMMON RULE
--filters
function cid.filter(c,ft)
	return c:IsFaceup() and c:IsCode(69537999) and c:IsAbleToGraveAsCost() and ((not c:IsLocation(LOCATION_MZONE) and ft>0) or (c:IsLocation(LOCATION_MZONE) and ft>0 or c:GetSequence()<5))
end
---------
function cid.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_ONFIELD,0,1,nil,ft)
end
function cid.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_ONFIELD,0,1,1,nil,ft)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
--ADD COUNTER
--filters
function cid.tgcfilter(c)
	return c:IsSetCard(0x32) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and (not c:IsOnField() or c:IsFaceup())
end
---------
function cid.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(cid.tgcfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,e:GetHandler()) and e:GetHandler():IsCanAddCounter(0xb9a,1)
	end
	e:SetLabel(0)
	local maxct=1
	if e:GetHandler():IsCanAddCounter(0xb9a,2) then maxct=2 end
	if e:GetHandler():IsCanAddCounter(0xb9a,3) then maxct=3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cid.tgcfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_MZONE,0,1,maxct,e:GetHandler())
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
		local sg=g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		e:SetLabel(sg)
		if e:GetLabel()+e:GetHandler():GetCounter(0xb9a)>10 then e:SetLabel(10-e:GetHandler():GetCounter(0xb9a)) end
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,e:GetLabel(),0,0xb9a)
	end
end
function cid.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsCanAddCounter(0xb9a,ct) then
		c:AddCounter(0xb9a,ct)
	end
end
--DAMAGE
--filters
function cid.thfilter(c)
	return (c:IsSetCard(0x32) or c:IsCode(69537999)) and c:IsAbleToHand()
end
---------
function cid.ctcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return e:GetHandler():GetCounter(0xb9a)>0 and e:GetHandler():IsCanRemoveCounter(tp,0xb9a,1,REASON_COST)
	end
	e:SetLabel(0)
	local ct={}
	for num=1,10 do
		if e:GetHandler():GetCounter(0xb9a)>=num and e:GetHandler():IsCanRemoveCounter(tp,0xb9a,num,REASON_COST) then
			table.insert(ct,num)
		end
	end
	if #ct>0 then
		local lv=Duel.AnnounceNumber(tp,table.unpack(ct))
		e:GetHandler():RemoveCounter(tp,0xb9a,lv,REASON_COST)
		e:SetLabel(lv*300)
	end
	if e:GetLabel()>0 then
		Duel.SetTargetPlayer(1-tp)
		Duel.SetTargetParam(e:GetLabel())
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel())
	end
end
function cid.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
	Duel.BreakEffect()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(cid.thcon)
	e1:SetOperation(cid.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cid.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end