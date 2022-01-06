--SKILL: Scorciatoia
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Shortcut
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
function cid.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
--Shortcut
function cid.skillcon_skill(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return aux.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE):FilterCount(Card.IsType,nil,TYPE_MONSTER)
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_CARD,1-tp,id)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<Duel.GetFieldGroup(tp,0,LOCATION_GRAVE):FilterCount(Card.IsType,nil,TYPE_MONSTER) then return end
	local ct=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE):FilterCount(Card.IsType,nil,TYPE_MONSTER)
	if Duel.DiscardDeck(tp,ct,REASON_RULE)~=0 then
		local g=Duel.GetOperatedGroup()
		if g:GetCount()==ct then
			g:KeepAlive()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,1)
			e1:SetValue(cid.aclimit)
			e1:SetLabelObject(g)
			if Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()~=tp then
				e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
			else
				e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			end
			Duel.RegisterEffect(e1,tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=Duel.SelectMatchingCard(tp,cid.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
			if #sg>0 then
				Duel.SendtoHand(sg,nil,REASON_RULE)
				Duel.ConfirmCards(1-tp,sg)
			end
		end
	end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
	return
end
function cid.aclimit(e,re,tp)
	local g=e:GetLabelObject()
	return g:IsContains(re:GetHandler())
end