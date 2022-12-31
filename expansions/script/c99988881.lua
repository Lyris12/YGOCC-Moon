--SKILL: Portale Link
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Link Portal
	local SKILL=Effect.CreateEffect(c)
	SKILL:SetType(EFFECT_TYPE_FIELD)
	SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	SKILL:SetRange(LOCATION_EXTRA)
	SKILL:SetCode(EFFECT_SPSUMMON_PROC_G)
	SKILL:SetCondition(cid.skillcon_skill)
	SKILL:SetOperation(cid.skillop)
	SKILL:SetValue(SUMMON_TYPE_SPECIAL+1)
	c:RegisterEffect(SKILL)
end
--filters
--Link Portal
function cid.skillcon_skill(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return aux.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0 and Duel.CheckLocation(tp,LOCATION_SZONE,2)
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_CARD,1-tp,id)
	if not Duel.CheckLocation(tp,LOCATION_SZONE,2) then return end
	local card=Duel.CreateToken(tp,9998881)
	Duel.MoveToField(card,tp,tp,LOCATION_SZONE,POS_FACEUP_ATTACK,true,0x4)
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	return
end