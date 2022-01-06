--SKILL: Conservazione della Specie
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Species Preservation
	local SKILL=Effect.CreateEffect(c)
	SKILL:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	SKILL:SetRange(LOCATION_EXTRA)
	SKILL:SetCode(EVENT_SPSUMMON_SUCCESS)
	SKILL:SetCountLimit(1)
	SKILL:SetCondition(cid.skillcon_skill)
	SKILL:SetOperation(cid.skillop)
	c:RegisterEffect(SKILL)
end
--filters
function cid.cfilter(c,zone)
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		if c:IsControler(1) then seq=seq+16 end
	else
		seq=c:GetPreviousSequence()
		if c:GetPreviousControler()==1 then seq=seq+16 end
	end
	return bit.extract(zone,seq)~=0 and c:IsType(TYPE_LINK) and c:IsType(TYPE_MONSTER)
end
function cid.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:GetAttack()>0
end
--Species Preservation
function cid.skillcon_skill(e,tp,eg,ep,ev,re,r,rp)
	local zone=Duel.GetLinkedZone(0)+(Duel.GetLinkedZone(1)<<0x10)
	return aux.skillcon(e) and eg:IsExists(cid.cfilter,1,nil,zone) and Duel.IsExistingMatchingCard(cid.atkfilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetLP(tp)<=Duel.GetLP(1-tp)
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(cid.atkfilter,tp,0,LOCATION_MZONE,1,nil) or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,cid.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		tc:RegisterEffect(e1)
	end
end