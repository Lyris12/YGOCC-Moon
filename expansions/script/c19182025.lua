--Faircaster Yata
--created by Alastar Rainford, coded by Lyris
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--excavate
	local ex=aux.AddAircasterExcavateEffect(c,3,EFFECT_TYPE_QUICK_O,0,id,nil)
	--equip
	aux.AddAircasterEquipEffect(c,1)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:HOPT()
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--banish
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2x:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2x:SetOperation(function(E)
		local C=E:GetHandler()
		if not C:IsFaceup() then return end
		C:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,STRING_BANISH_REDIRECT)
	end)
	c:RegisterEffect(e2x)
	local e2y=Effect.CreateEffect(c)
	e2y:SetType(EFFECT_TYPE_SINGLE)
	e2y:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e2y:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT)
	e2y:SetCondition(function(E)
		return E:GetHandler():HasFlagEffect(id) and not s.PreventWrongRedirect
	end)
	e2y:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2y)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetCondition(function(E)
		return E:GetHandler():HasFlagEffect(id) and not s.PreventWrongRedirect
	end)
	e2:SetOperation(s.bfdop)
	c:RegisterEffect(e2)
	--equip effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_ADD_TYPE)
	e3:SetValue(TYPE_TUNER)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CHANGE_LEVEL)
	e4:SetValue(3)
	c:RegisterEffect(e4)
end
s.PreventWrongRedirect=false

function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_AIRCASTER) and c:IsAbleToGraveAsCost() and c:GetSequence()<5
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetMatchingGroup(aux.Faceup(Card.HasLevel),tp,LOCATION_MZONE,0,nil)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(3)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end

function s.bfdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	s.PreventWrongRedirect=true
	if Duel.Remove(c,POS_FACEDOWN,c:GetReason()|REASON_REDIRECT)>0 and c:IsBanished(POS_FACEDOWN) then
		local fid=c:GetFieldID()
		c:RegisterFlagEffect(id+100,RESET_EVENT|(RESETS_STANDARD&(~RESET_REMOVE)),EFFECT_FLAG_SET_AVAILABLE,1,fid)
		local rct=Duel.GetNextPhaseCount(PHASE_END,tp)
		local tct=(rct>1) and Duel.GetTurnCount() or 0
		local de=Effect.CreateEffect(c)
		de:Desc(3)
		de:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		de:SetCode(EVENT_PHASE|PHASE_END)
		de:SetCountLimit(1)
		de:SetLabel(fid,tct)
		de:SetLabelObject(c)
		de:SetCondition(s.descon)
		de:SetOperation(s.desop)
		de:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,rct)
		Duel.RegisterEffect(de,tp)
	end
	s.PreventWrongRedirect=false
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local fid,tct=e:GetLabel()
	local c=e:GetLabelObject()
	if not c or not c:HasFlagEffectLabel(id+100,fid) then
		e:Reset()
		return false
	end
	return Duel.GetTurnPlayer()==tp and Duel.GetTurnCount()~=tct
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject()
	Duel.Hint(HINT_CARD,0,id)
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
