--Alchemage Manabolt
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cid=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cid
end
local id,cid=getID()
function cid.initial_effect(c)
	--atkdown
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	--e1:SetCountLimit(1,id)
	e1:SetCost(cid.ccost)
	e1:SetTarget(cid.atktg)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
	--tohand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(cid.spcon)
	e3:SetTarget(cid.thtg)
	e3:SetOperation(cid.thop)
	c:RegisterEffect(e3)
end
--Filters
function cid.filter(c)
	return (c:IsCode(21770262) or c:IsCode(21770263) or c:IsCode(21770264))
end
function cid.cfilter(c)
	return (c:IsCode(21770262) or c:IsCode(21770263) or c:IsCode(21770264)) and c:IsPreviousLocation(LOCATION_MZONE) 
end
--ATK Down
function cid.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x81081,1,REASON_COST) end
	local ct={}
	local countmax=Duel.GetCounter(tp,1,0,0x81081)
	e:SetLabel(0)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
		for i=countmax,1,-1 do
			if Duel.IsCanRemoveCounter(tp,1,0,0x81081,i,REASON_COST)  then
				table.insert(ct,i)
			end
		end
		if #ct==1 then 
			Duel.RemoveCounter(tp,1,0,0x81081,1,REASON_COST)
			e:SetLabel(1)
		else
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
			Duel.RemoveCounter(tp,1,0,0x81081,ac,REASON_COST)
			e:SetLabel(ac)
		end
	end
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(cid.filter,tp,LOCATION_MZONE,0,nil)
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local preatk=tc:GetAttack()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-500*ct-200*e:GetLabel())
	tc:RegisterEffect(e1)
	if preatk~=0 and tc:IsAttack(0) then
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,e:GetHandler())  then
			local cc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
			cc:GetFirst():AddCounter(0x81081,5)
		end
	end
end
--Add back to hand
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.cfilter,1,nil,tp)
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
