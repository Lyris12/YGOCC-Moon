--Scarlet Engima - Prodigy
function c249000645.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75878039,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetTarget(c249000645.target)
	e1:SetOperation(c249000645.operation)
	c:RegisterEffect(e1)
	--special summon 
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(aux.exccon)
	e2:SetCost(c249000645.cost2)
	e2:SetTarget(c249000645.target2)
	e2:SetOperation(c249000645.operation2)
	c:RegisterEffect(e2)
end
function c249000645.filter(c)
	return c:IsSetCard(0x1E2) and c:IsAbleToHand() and not c:IsCode(249000645)
end
function c249000645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000645.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c249000645.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c249000645.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c249000645.disfilter(c)
	return c:IsSetCard(0x1E2) and c:IsDiscardable()
end
function c249000645.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000645.disfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,c249000645.disfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c249000645.filter1(c,e,tp)
	return c:GetLevel() > 4 and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(c249000645.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel())
end
function c249000645.filter2(c,e,tp,lv)
	return c:GetRank()==lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c249000645.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249000645.filter1,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp)
		and e:GetHandler():IsAbleToRemove() and Duel.GetLocationCount(tp,LOCATION_MZONE) < 0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function c249000645.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE) < 1 then return end
	local g=Duel.SelectMatchingCard(tp,c249000645.filter1,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	if g:GetCount()>0 then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		local sg=Duel.SelectMatchingCard(tp,c249000645.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,g:GetFirst():GetLevel())
		if sg:GetCount()>0 and Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
			local sc=sg:GetFirst()
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			sc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+0x1fe0000)
			sc:RegisterEffect(e2)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e3:SetReset(RESET_EVENT+0x1fe0000)
			sc:RegisterEffect(e1,true)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetCountLimit(1)
			e3:SetRange(LOCATION_MZONE)
			e3:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			e3:SetCondition(c249000645.retcon)
			e3:SetOperation(c249000645.retop)
			sc:RegisterEffect(e3)
		end
		Duel.SpecialSummonComplete()
	end
end
function c249000645.retcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp
end
function c249000645.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoDeck(e:GetHandler(),nil,0,REASON_EFFECT)
end