--Familiar Possessed - Kamiya
function c249001150.initial_effect(c)
	--special summon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c249001150.spcon)
	e1:SetOperation(c249001150.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(506)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c249001150.condition)
	e2:SetTarget(c249001150.thtg)
	e2:SetOperation(c249001150.thop)
	c:RegisterEffect(e2)
	--Double ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86943389,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(c249001150.atkcon)
	e3:SetOperation(c249001150.atkop)
	c:RegisterEffect(e3)
end
function c249001150.spfilter1(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xBF) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(c249001150.spfilter2,tp,LOCATION_MZONE,0,1,c)
end
function c249001150.spfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGraveAsCost()
end
function c249001150.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>-2
		and Duel.IsExistingMatchingCard(c249001150.spfilter1,tp,LOCATION_MZONE,0,1,nil,tp)
end
function c249001150.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,c249001150.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,c249001150.spfilter2,tp,LOCATION_MZONE,0,1,1,g1:GetFirst())
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_COST)
end
function c249001150.thfilter(c)
	return c:IsRace(RACE_DIVINE) and c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsAbleToHand()
end
function c249001150.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF or (c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetReasonEffect():GetHandler():IsSetCard(0xC0))
end
function c249001150.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001150.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c249001150.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c249001150.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(78364470,0))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_DIVINE))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function c249001150.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF or (c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetReasonEffect():GetHandler():IsSetCard(0xC0))) then return false end
	local bc=c:GetBattleTarget()
	return bc and bc:IsSummonType(SUMMON_TYPE_SPECIAL)
end
function c249001150.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
