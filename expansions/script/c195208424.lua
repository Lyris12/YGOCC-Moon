--False Reailty Wrath Bringer Makolo
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1109)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+500)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--burn ~Lyris
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetCost(s.cost)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return true end Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetLabelObject(),1,0,0) end)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
	function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
	function s.thfilter1(c)
	return c:IsSetCard(0x83e) and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
	function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
	function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if tg:GetCount()>0 then 
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	end
end
--code below by Lyris
	function s.filter(c)
	return not c:IsPublic() and c:IsSetCard(0x83e) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
	function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND,0,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
	function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local mc=e:GetLabelObject()
	if not mc or Duel.Remove(mc,POS_FACEUP,REASON_EFFECT)==0 or not mc:IsLocation(LOCATION_REMOVED) then return end
	Duel.BreakEffect()
	local flag=0
	for i=0,1 do
		if Duel.SelectOption(tp,aux.Stringid(id//10-2,0),aux.Stringid(id//10-2,1))==0 then
			flag=flag|Duel.SelectDisableField(tp,1,LOCATION_ONFIELD,LOCATION_ONFIELD,flag)
		else
			local tc=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):FilterSelect(tp,s.cfilter,1,1,nil,~flag):GetFirst()
			flag=flag|2^(tc:GetSequence()+(tc:IsLocation(LOCATION_SZONE) and 8 or 0)+(tc:IsControler(1) and 16 or 0))
		end
		if i==0 and not Duel.SelectYesNo(tp,210) then break end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(function(e,tp,eg) return eg:IsExists(s.cfilter,1,nil,flag) end)
	e1:SetOperation(function(e,tp,eg)
		Duel.Hint(HINT_CARD,0,id)
		if eg:IsExists(s.pfilter,1,nil,0) then Duel.Damage(0,500,REASON_EFFECT,true) end
		if eg:IsExists(s.pfilter,1,nil,1) then Duel.Damage(1,500,REASON_EFFECT,true) end
		Duel.RDComplete()
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EVENT_MSET)
	Duel.RegisterEffect(e4,tp)
	local e5=e1:Clone()
	e5:SetCode(EVENT_SSET)
	Duel.RegisterEffect(e5,tp)
	local e6=e1:Clone()
	e6:SetCode(EVENT_CHAINING)
	e6:SetCondition(function(e,tp,eg,ep,ev,re)
		return re:IsHasType(EFFECT_TYPE_ACTIVATE) and bit.extract(flag,re:GetActivateSequence()+8)~=0
	end)
	Duel.RegisterEffect(e6,tp)
end
	function s.cfilter(c,zone)
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_ONFIELD) then if c:IsControler(1) then seq=seq+16 end
	else
		seq=c:GetPreviousSequence()
		if c:GetPreviousControler()==1 then seq=seq+16 end
	end
	if c:IsLocation(LOCATION_SZONE) then seq=seq+8 end
	return bit.extract(zone,seq)~=0
end
	function s.pfilter(c,p)
	return c:GetPreviousControler()==p or c:IsControler(p)
end
