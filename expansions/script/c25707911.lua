--Balvalur, Wisprit Grandmaster
local cid,id=GetID()
function cid.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.thcost)
	e1:SetTarget(cid.thtg)
	e1:SetOperation(cid.thop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+17)
	e2:SetCondition(cid.condition)
	e2:SetCost(cid.cost)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.operation)
	c:RegisterEffect(e2)
end
--filters
function cid.thfilter(c)
	return c:IsCode(25707917) and c:IsAbleToHand()
end
function cid.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cid.thfilter1(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsLocation(LOCATION_DECK) or c:IsFaceup()) and c:IsSetCard(0x26c) and c:IsAbleToHand()
end
--tohand
function cid.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
function cid.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		and Duel.IsExistingMatchingCard(cid.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cid.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)>0 then
	   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	   local g=Duel.SelectMatchingCard(tp,cid.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	   if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	  end
   end
end
--to hand
function cid.condition(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b={true,true,true}
	b[1]=Duel.IsExistingMatchingCard(cid.thfilter1,tp,LOCATION_DECK,0,1,nil)
	b[2]=Duel.IsExistingMatchingCard(cid.thfilter1,tp,LOCATION_GRAVE,0,1,nil)
	b[3]=Duel.IsExistingMatchingCard(cid.thfilter1,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return (b[1] or b[2] or b[3]) and Duel.IsExistingMatchingCard(cid.cfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	e:SetLabel(0)
	local rt=3
	for i=1,3 do
		if not b[i] then rt=rt-1 end
	end
	if rt<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rct=Duel.SelectMatchingCard(tp,cid.cfilter,tp,LOCATION_GRAVE,0,1,rt,nil)
	if #rct<=0 then return end
	local ct=Duel.Remove(rct,POS_FACEUP,REASON_COST)
	if ct<=0 then return end
	local sel,off,maxsel=0,0,0
	repeat
		local ops={}
		local opval={}
		off=2
		if b[1] then
			ops[off-1]=aux.Stringid(id,3)
			opval[off-1]=1
			off=off+1
		end
		if b[2] then
			ops[off-1]=aux.Stringid(id,4)
			opval[off-1]=2
			off=off+1
		end
		if b[3] then
			ops[off-1]=aux.Stringid(id,5)
			opval[off-1]=3
			off=off+1
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		if opval[op]==1 then
			sel=sel|0x1
			maxsel=maxsel+1
			b[1]=false
		elseif opval[op]==2 then
			sel=sel|0x2
			maxsel=maxsel+1
			b[2]=false
		else
			sel=sel|0x4
			maxsel=maxsel+1
			b[3]=false
		end
		ct=ct-1
	until (ct==0 or maxsel>=3 or off<3)
	e:SetLabel(sel)
	if bit.band(sel,0x1)~=0 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
	if bit.band(sel,0x2)~=0 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
	if bit.band(sel,0x4)~=0 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	end
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if bit.band(sel,0x1)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,cid.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if bit.band(sel,0x2)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cid.thfilter1),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if bit.band(sel,0x4)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,cid.thfilter1,tp,LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end