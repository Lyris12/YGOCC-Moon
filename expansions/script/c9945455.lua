--Phases of the Zodiac
function c9945455.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c9945455.target)
	e1:SetOperation(c9945455.activate)
	c:RegisterEffect(e1)
	--inaff
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9945455,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,9945455)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c9945455.cost)
	e2:SetCondition(c9945455.condition)
	e2:SetTarget(c9945455.intg)
	e2:SetOperation(c9945455.inop)
	c:RegisterEffect(e2)
end
function c9945455.spfilter(c,e,tp)
	return c:IsSetCard(0x12D7) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) and c:IsType(TYPE_RITUAL)
end
function c9945455.tfilter(c)
	return c:IsSetCard(0x12D7) and c:IsType(TYPE_MONSTER)
end
function c9945455.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(c9945455.tfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
    if chk==0 then 
        return Duel.GetLocationCountFromEx(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>-3 
            and g:GetClassCount(Card.GetCode)>=3 and Duel.IsExistingMatchingCard(c9945455.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    end
end
function c9945455.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<-3 then return end
	local g=Duel.GetMatchingGroup(c9945455.tfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,nil)
	if g:GetClassCount(Card.GetCode)>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g1=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g2=g:Select(tp,1,1,nil)
		g:Remove(Card.IsCode,nil,g2:GetFirst():GetCode())
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g3=g:Select(tp,1,1,nil)
		g1:Merge(g2)
		g1:Merge(g3)
		Duel.Release(g1,REASON_RITUAL)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g4=Duel.SelectMatchingCard(tp,c9945455.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local tc=g4:GetFirst()
			if tc then
			tc:SetMaterial(g1)
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
	end
end
function c9945455.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12D7)
end
function c9945455.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function c9945455.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function c9945455.intg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9945455.cfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c9945455.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c9945455.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c9945455.inop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local ph=Duel.GetCurrentPhase()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_PHASE+(ph)+RESET_EVENT+0x1fc0000)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end