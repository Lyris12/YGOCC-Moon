--Markshalling Field
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:GLString(0)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
	--setcard and protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_ADD_SETCODE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0xff,0xff)
	e2:SetTarget(cid.target)
	e2:SetValue(0x7a4)
	c:RegisterEffect(e2)
	local e2y=e2:Clone()
	e2y:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2y:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2y:SetTargetRange(LOCATION_MZONE,0)
	e2y:SetValue(aux.indoval)
	c:RegisterEffect(e2y)
	--negate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cid.discon)
	e3:SetCost(cid.discost)
	e3:SetTarget(cid.distg)
	e3:SetOperation(cid.disop)
	c:RegisterEffect(e3)
end
--ACTIVATE
function cid.thfilter(c,e)
	return c:IsSetCard(0x7a4) and (c:IsAbleToHand() or c:IsDestructable(e)) and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup())
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(cid.thfilter,tp,LOCATION_DECK,0,nil,e)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		if not tc then return end
		local b1=tc:IsDestructable(e)
		local b2=tc:IsAbleToHand()
		local b={b1,b2}
		if not b[1] and not b[2] then return end
		local off=1
		local ops={}
		local opval={}
		for i=1,2 do
			if b[i] then
				ops[off]=aux.Stringid(id,i+1)
				opval[off]=i-1
				off=off+1
			end
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then
			Duel.Destroy(tc,REASON_EFFECT)
		elseif sel==1 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end

--SETCARD
function cid.target(e,c)
	return c:IsCode(63553466,63553468,63553469,63553470) and c:GetOwner()==e:GetHandlerPlayer()
end

--NEGATE
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return not e:IsHasType(EFFECT_TYPE_ACTIVATE) and tg and tg:IsContains(c) and Duel.IsChainNegatable(ev)
end
function cid.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and not c:IsType(TYPE_EXTRA) and c:IsAbleToDeckAsCost()
end
function cid.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_EXTRA+LOCATION_HAND,0,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_COST)
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
end
