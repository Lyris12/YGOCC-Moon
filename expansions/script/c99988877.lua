--SKILL: Cura Segreta
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Storm Access
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
function cid.checkcard(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cid.rmfilter(c,seq)
	return c:GetSequence()>=seq
end
--Storm Access
function cid.skillcon_skill(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return aux.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_CARD,1-tp,id)
	local g=Duel.GetMatchingGroup(cid.checkcard,tp,LOCATION_DECK,0,nil)
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	if #g<=0 then
		Duel.ConfirmDecktop(tp,dcount)
		Duel.ShuffleDeck(tp)
		return
	end
	local seq=-1
	local tc=g:GetFirst()
	local spcard=nil
	while tc do
		if tc:GetSequence()>seq then 
			seq=tc:GetSequence()
			spcard=tc
		end
		tc=g:GetNext()
	end
	Duel.ConfirmDecktop(tp,dcount-seq)
	if spcard:IsAbleToHand() then
		Duel.DisableShuffleCheck()
		local val=0
		if Duel.SendtoHand(spcard,nil,REASON_RULE)~=0 then
			if Duel.GetOperatedGroup():GetFirst():IsLocation(LOCATION_HAND) then
				val=Duel.GetOperatedGroup():GetFirst():GetTextAttack()
			end
		end
		local rm=Duel.GetMatchingGroup(cid.rmfilter,tp,LOCATION_DECK,0,nil,seq)
		Duel.Remove(rm,POS_FACEDOWN,REASON_RULE+REASON_REVEAL)
		Duel.ConfirmCards(1-tp,spcard)
		Duel.ShuffleHand(tp)
		if val>0 then
			for p=0,1 do
				Duel.Recover(p,val,REASON_RULE)
			end
		end
	else 
		local rm=Duel.GetMatchingGroup(cid.rmfilter,tp,LOCATION_DECK,0,nil,seq)
		Duel.Remove(rm,POS_FACEDOWN,REASON_RULE+REASON_REVEAL)
	end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	return
end