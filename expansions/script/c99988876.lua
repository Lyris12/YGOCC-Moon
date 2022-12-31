--SKILL: Trucco Ingannevole
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigSkillType(c)
	--ED Skill Properties
	aux.EDSkillProperties(c)
	--Tricky Trick
	local SKILL=Effect.CreateEffect(c)
	SKILL:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	SKILL:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	SKILL:SetRange(LOCATION_EXTRA)
	SKILL:SetCode(EVENT_PREDRAW)
	SKILL:SetCountLimit(1)
	SKILL:SetCondition(cid.skillcon_skill)
	SKILL:SetOperation(cid.skillop)
	c:RegisterEffect(SKILL)
end
--filters
function cid.dfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4) and c:IsDiscardable()
end
--Tricky Trick
function cid.skillcon_skill(e,tp,eg,ep,ev,re,r,rp)
	return aux.skillcon(e) and Duel.GetFlagEffect(tp,id)<=0 and tp~=Duel.GetTurnPlayer() 
		and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>1 and Duel.GetDrawCount(1-tp)>0
		and Duel.IsExistingMatchingCard(cid.dfilter,tp,LOCATION_HAND,0,1,nil)
end
function cid.skillop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)<=1 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,1-tp,id)
	local g=Duel.GetMatchingGroup(cid.dfilter,tp,LOCATION_HAND,0,nil)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=g:Select(tp,1,1,nil)
	if Duel.SendtoGrave(tc,REASON_RULE+REASON_DISCARD)~=0 then
		local lv=Duel.GetOperatedGroup():GetFirst():GetLevel()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(2)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(lv)
		e2:SetOperation(cid.rmop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	end
	Duel.RegisterFlagEffect(tp,id,0,0,1)
end
function cid.rmop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	if not lv or lv<=0 then return end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_ONFIELD)
	if #g<lv then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
	local rg=g:FilterSelect(1-tp,Card.IsAbleToRemove,lv,lv,nil)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_RULE)
	end
end