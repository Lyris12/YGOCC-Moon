--Sakura Elf of Gust VINE
function c50031841.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50031841,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c50031841.target)
	e1:SetOperation(c50031841.activate)
	c:RegisterEffect(e1)
	--activate trap in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,50031841)
	e2:SetOperation(c50031841.operation)
	c:RegisterEffect(e2)
		--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCondition(c50031841.atkcon)
	e4:SetOperation(c50031841.atkop)
	c:RegisterEffect(e4)
end
function c50031841.filter(c)
	return c:IsSetCard(0x885a)  and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c50031841.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_REMOVED,nil,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_REMOVED,nil,1,1,nil)
	local g1=g:GetFirst()
	if g1 and g1:IsType(TYPE_MONSTER) and g1:IsSetCard(0x885a) and g1:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		e:SetCategory(CATEGORY_RECOVER+CATEGORY_SPECIAL_SUMMON)
	end
end
function c50031841.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsControler(tp)
		and tc:IsType(TYPE_MONSTER)  and tc:IsLocation(LOCATION_HAND) and tc:IsSetCard(0x885a) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(50031841,1))
	then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
	end

function c50031841.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function c50031841.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local res=r&(REASON_FUSION+REASON_EVOLUTE)
	return res==REASON_FUSION or res==REASON_EVOLUTE  
end
function c50031841.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+0x1fe0000)
	rc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	rc:RegisterEffect(e2)
end
