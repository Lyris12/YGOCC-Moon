--Noire
--coded by Concordia,Cred André and Moon_Burst
function c68709327.initial_effect(c)
    --atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,68709327)
	e1:SetOperation(c68709327.atkop)
	c:RegisterEffect(e1)
	--float
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68709327,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,68709427)
	e2:SetTarget(c68709327.target)
	e2:SetOperation(c68709327.operation)
	c:RegisterEffect(e2)
end
function c68709327.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(300)
        e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_BATTLE)
        c:RegisterEffect(e1)
    end
end
function c68709327.filter(c,e,tp)
	return c:IsSetCard(0xf08) and not c:IsCode(68709327) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c68709327.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c68709327.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c68709327.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c68709327.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c68709327.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
function c68709327.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xf08,0xf09)
end