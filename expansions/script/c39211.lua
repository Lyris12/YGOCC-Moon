--Junkdust Ghost
--Automate ID

local scard,s_id=GetID()
function scard.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(scard.atkcon)
	e1:SetCost(scard.atkcost)
	e1:SetTarget(scard.atktg)
	e1:SetOperation(scard.atkop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(scard.sptg)
	e2:SetOperation(scard.spop)
	c:RegisterEffect(e2)
end
function scard.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local b1,b2=Duel.GetBattleMonster(tp),Duel.GetBattleMonster(1-tp)
	return b1 and b1:IsFaceup() and b1:IsSetCard(0x43) and b2
end
function scard.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function scard.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return scard.atkcon(e,tp,eg,ep,ev,re,r,rp)
	end
	local b1=Duel.GetBattleMonster(tp)
	Duel.SetTargetCard(b1)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,b1,1,b1:GetControler(),b1:GetLocation(),{b1:GetAttack()*2})
end
function scard.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
	end
end

function scard.spfilter(c,e,tp)
	return c:NotBanishedOrFaceup() and c:IsSetCard(0x43,0xa3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function scard.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(scard.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_REMOVED)
end
function scard.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,scard.spfilter,tp,LOCATION_HAND+LOCATION_REMOVED,0,1,1,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
