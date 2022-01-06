--SKILL: Scoppio Ritardato
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Afterblow
	local SKILL=Effect.CreateEffect(c)
	SKILL:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	SKILL:SetRange(LOCATION_EXTRA)
	SKILL:SetCode(EVENT_DESTROYED)
	SKILL:SetCondition(cid.skillcon_skill)
	SKILL:SetOperation(cid.skillop)
	c:RegisterEffect(SKILL)
end
--filters
function cid.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==1-tp
		and c:GetReasonCard():IsControler(tp)
end
--Afterblow
function cid.skillcon_skill(e,tp,eg,ep,ev,re,r,rp)
	return aux.skillcon(e) and eg:IsExists(cid.cfilter,1,nil,tp)
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.Damage(1-tp,700,REASON_RULE)
end