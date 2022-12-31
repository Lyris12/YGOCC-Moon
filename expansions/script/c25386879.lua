--Steinitz's Queen
--Script by XGlitchy30
function c25386879.initial_effect(c)
	--fusion summon
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,c25386879.ffilter,3,true)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetValue(c25386879.splimit)
	c:RegisterEffect(e1)
	--limit attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c25386879.limit_atk_eq)
	c:RegisterEffect(e2)
	--direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3x:SetRange(LOCATION_MZONE)
	e3x:SetTargetRange(LOCATION_MZONE,0)
	e3x:SetTarget(c25386879.eftg)
	e3x:SetLabelObject(e3)
	c:RegisterEffect(e3x)
	local e3y=Effect.CreateEffect(c)
	e3y:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3y:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3y:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3y:SetCondition(c25386879.rdcon)
	e3y:SetOperation(c25386879.rdop)
	local e3xy=Effect.CreateEffect(c)
	e3xy:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3xy:SetRange(LOCATION_MZONE)
	e3xy:SetTargetRange(LOCATION_MZONE,0)
	e3xy:SetTarget(c25386879.eftg)
	e3xy:SetLabelObject(e3y)
	c:RegisterEffect(e3xy)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25386879,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,25386879)
	e4:SetTarget(c25386879.sptg)
	e4:SetOperation(c25386879.spop)
	c:RegisterEffect(e4)
end
--fusion filters
function c25386879.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x63d0) and not c:IsType(TYPE_FUSION) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
--filters
function c25386879.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x63d0)
end
--spsummon condition
function c25386879.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
--limit attack
function c25386879.limit_atk_eq(e,c)
	local lr1=e:GetHandler():GetColumnGroup(1,1)
	return lr1:IsContains(c)
end
--direct attack
function c25386879.eftg(e,c)
	return c:IsSetCard(0x63d0) and not c:IsType(TYPE_FUSION)
end
function c25386879.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget()==nil
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function c25386879.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev/2)
end
--spsummon
function c25386879.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function c25386879.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(c25386879.val)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			c:RegisterEffect(e1)
		end
	end
end
function c25386879.val(e,c)
	return Duel.GetMatchingGroupCount(c25386879.vfilter,c:GetControler(),LOCATION_MZONE,0,e:GetHandler())*200
end