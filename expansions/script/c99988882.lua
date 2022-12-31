--SKILL: Selezione Livello
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Stage Selection
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
function cid.checkfield(c)
	return bit.band(c:GetType(),0x80002)==0x80002
end
--Stage Selection
function cid.skillcon_skill(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local fc1,fc2=Duel.GetFieldCard(tp,LOCATION_SZONE,5),Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	return aux.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0 and not fc1 and not fc2
		and not Duel.IsExistingMatchingCard(cid.checkfield,tp,LOCATION_DECK,0,1,nil)
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_CARD,1-tp,id)
	local fc1,fc2=Duel.GetFieldCard(tp,LOCATION_SZONE,5),Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	if fc1 or fc2 or Duel.IsExistingMatchingCard(cid.checkfield,tp,LOCATION_DECK,0,1,nil) then return end
	cid.announce_filter={TYPE_FIELD,OPCODE_ISTYPE,TYPE_SPELL,OPCODE_ISTYPE,OPCODE_AND}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCardFilter(tp,table.unpack(cid.announce_filter))
	for i=0,1 do
		local card=Duel.CreateToken(i,ac)
		Duel.MoveToField(card,tp,i,LOCATION_SZONE,POS_FACEUP_ATTACK,true)
	end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	return
end