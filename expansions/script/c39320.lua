function c39320.initial_effect(c)
	c:EnableUnsummonable()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c39320.spcon)
	e1:SetTarget(c39320.sptg)
	e1:SetOperation(c39320.spop)
	c:RegisterEffect(e1)
	--cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c39320.tgtg)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	--double damage
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c39320.damcon)
	e3:SetOperation(c39320.damop)
	c:RegisterEffect(e3)
end
	function c39320.cfilter(c,tp)
	return c:IsReason(REASON_DESTROY) and c:IsType(TYPE_MONSTER) and c:GetPreviousControler()==tp
end
function c39320.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39320.cfilter,1,nil,1-tp)
end
function c39320.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c39320.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
function c39320.tgtg(e,c)
	return c~=e:GetHandler() and c:IsFaceup() and c:GetCode()>39300 and c:GetCode()<39322 and not c:IsCode(39311,39312)
end
function c39320.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return ep~=tp and tc:GetCode()>39300 and tc:GetCode()<39326 and not tc:IsCode(39311,39312) and tc:GetBattleTarget()~=nil
end
function c39320.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end