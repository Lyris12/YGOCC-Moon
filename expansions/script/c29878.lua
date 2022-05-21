--O. Numero 120: Re Occhio, Sovrano di Golagelatyna
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x296),3,3)
	c:EnableReviveLimit()
	--protection
	local e1=c:EffectProtection(true)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.etg)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
	--search
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
	--
	c:SSCounter(s.counterfilter)
end
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) or c:IsRace(RACE_AQUA)
end

function s.etg(e,c)
	return c:IsMonster() and c:IsSetCard(0x296) and not c:IsCode(id)
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end

function s.filter(c,e,tp)
	return c:NotBanishedOrFaceup() and c:IsMonster() and c:IsSetCard(0x296) and (c:IsAbleToHand() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.DetachSelfCost()(e,tp,eg,ep,ev,re,r,rp,chk) and aux.SSLimit(s.counterfilter,1)(e,tp,eg,ep,ev,re,r,rp,chk) end
	aux.SSLimit(s.counterfilter,1)(e,tp,eg,ep,ev,re,r,rp,chk)
	aux.DetachSelfCost()(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and tc:IsAbleToHand() and (not (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)) or Duel.SelectOption(tp,1190,1152)==0) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
	else
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end