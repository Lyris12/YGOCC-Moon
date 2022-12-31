--SKILL: Accesso Tempesta
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--ED Skill Properties
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(cid.skillcon)
	e1:SetValue(cid.efilter)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(0)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_USE_AS_COST)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--Storm Access
	local SKILL=Effect.CreateEffect(c)
	SKILL:SetType(EFFECT_TYPE_FIELD)
	SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_SINGLE_RANGE)
	SKILL:SetRange(LOCATION_EXTRA)
	SKILL:SetCode(EFFECT_SPSUMMON_PROC_G)
	SKILL:SetCondition(cid.skillcon_skill)
	SKILL:SetOperation(cid.skillop)
	SKILL:SetValue(SUMMON_TYPE_SPECIAL+1)
	c:RegisterEffect(SKILL)
end
--filters
function cid.skillcon(e)
	return e:GetHandler():IsFaceup() and e:GetHandler():GetFlagEffect(99988871)>0
end
function cid.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
--Storm Access
function cid.skillcon_skill(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return cid.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0 and Duel.GetLP(tp)<=1000
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_CARD,1-tp,id)
	cid.announce_filter={RACE_CYBERSE,OPCODE_ISRACE,TYPE_LINK,OPCODE_ISTYPE,OPCODE_AND}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCardFilter(tp,table.unpack(cid.announce_filter))
	local card=Duel.CreateToken(tp,ac)
	Duel.Remove(card,POS_FACEUP,REASON_RULE)
	Duel.SendtoDeck(card,tp,0,REASON_RULE)
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	return
end