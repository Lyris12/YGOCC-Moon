--SKILL: Tecnica Riryoku
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Riryoku Technique
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
function cid.filter(c,tp,mode)
	if not mode then return false end
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and (mode==1 or (c:GetAttack()~=0 and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,tp,1)))
end
function cid.checklabel(c,card)
	return c==card
end
--Riryoku Technique
function cid.skillcon_skill(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return aux.skillcon(e) and (Duel.GetFlagEffect(tp,id)<=0 or Duel.GetFlagEffectLabel(tp,id)<3)
		and Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,0)
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_CARD,1-tp,id)
	if not Duel.IsExistingMatchingCard(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,0) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g1=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,0)
	if #g1<=0 then return end
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g2=Duel.SelectMatchingCard(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst(),tp,1)
	if #g2<=0 then return end
	g1:Merge(g2)
	if #g1==2 then
		Duel.HintSelection(g1)
		local tc=g1:Filter(cid.checklabel,nil,e:GetLabelObject()):GetFirst()
		local val=tc:GetAttack()
		g1:RemoveCard(tc)
		local tc2=g1:GetFirst()
		if not tc:IsFaceup() or not tc2:IsFaceup() then return end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(0)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(val)
		tc2:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CHANGE_DAMAGE)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(1,0)
		e3:SetValue(0)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,1-tp)
		local e4=e3:Clone()
		e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
		e4:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e4,1-tp)
	end
	if Duel.GetFlagEffect(tp,id)<=0 then
		Duel.RegisterFlagEffect(tp,id,0,0,1)
		Duel.SetFlagEffectLabel(tp,id,1)
	else
		Duel.SetFlagEffectLabel(tp,id,Duel.GetFlagEffectLabel(tp,id)+1)
	end
	return
end