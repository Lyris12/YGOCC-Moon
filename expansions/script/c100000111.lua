--Aeonstrider Adrift
--Marciaeoni alla Deriva
--Scripted by: XGlitchy30

local s,id=GetID()
xpcall(function() require("expansions/script/glitchylib_helper") end,function() require("script/glitchylib_helper") end)
xpcall(function() require("expansions/script/glitchylib_aeonstride") end,function() require("script/glitchylib_aeonstride") end)
function s.initial_effect(c)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	--[[If the Turn Count is 2+: Add 1 "Aeonstride" Pendulum Monster from your hand, field, or GY, to the Extra Deck, face-up;
	move the Turn Count backwards by 1 turn, then you can banish 1 "Aeonstride" card from your Deck, but add it to your hand the next time the Turn Count moves forwards.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetFunctions(s.condition,s.cost,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[If an "Aeonstride" monster(s) you control would leave the field by an opponent's card effect, you can shuffle this banished card into the Deck and banish that monster(s)
	until the next End Phase, instead.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetFunctions(nil,nil,s.gytg,nil,s.gyop)
	c:RegisterEffect(e2)
end
--FE1
function s.cfilter(c,tp)
	return c:IsMonster(TYPE_PENDULUM) and c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsFaceupEx() and c:IsAbleToExtraFaceupAsCost(tp)
end
function s.rmfilter(c)
	return c:IsSetCard(ARCHE_AEONSTRIDE) and c:IsAbleToRemove()
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount(nil,true)>=2
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.cfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TOEXTRA,false,tp,s.cfilter,tp,LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.SendtoExtraP(g,nil,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanMoveTurnCount(-1,e,tp,REASON_EFFECT) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.MoveTurnCountCustom(-1,e,tp,REASON_EFFECT)~=0 and Duel.IsExists(false,s.rmfilter,tp,LOCATION_DECK,0,1,nil) and c:AskPlayer(tp,STRING_ASK_BANISH) then
		local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			local tc=g:GetFirst()
			Duel.BreakEffect()
			if Duel.Banish(tc)>0 and tc:IsBanished() then
				local fid=e:GetFieldID()
				tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_TURN_COUNT_MOVED)
				e1:SetLabel(fid)
				e1:SetLabelObject(tc)
				e1:SetFunctions(s.retcon,nil,nil,s.retop)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:HasFlagEffectLabel(id,e:GetLabel()) then
		e:Reset()
		return false
	end
	return ev>0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local tc=e:GetLabelObject()
	Duel.Search(tc,tp)
	e:Reset()
end

--FE2
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsMonster() and c:GetDestination()&LOCATION_ONFIELD==0 and c:IsAbleToRemove()
end
--E2
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (r&REASON_EFFECT)~=0 and rp==1-tp and eg:IsExists(s.repfilter,1,nil,tp) and c:IsAbleToDeck()
	end
	if c:AskPlayer(tp,3) then
		local g=eg:Filter(s.repfilter,nil,tp)
		local ct=#g
		if ct>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			g=g:Select(tp,1,ct,nil)
		end
		Duel.Hint(HINT_CARD,tp,id)
		Duel.HintSelection(g)
		local fid=e:GetFieldID()
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&(~(RESET_REMOVE|RESET_LEAVE)))|RESET_PHASE|PHASE_END,0,1,fid)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
		e1:SetCode(EVENT_REMOVE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetCondition(s.retcon2)
		e1:SetOperation(s.retop2)
		Duel.RegisterEffect(e1,tp)
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		return true
	else
		return false
	end
end
function s.gyop(e,c)
	return false
end
function s.retcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.HasFlagEffectLabel,1,nil,id,e:GetLabel())
end
function s.retop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.HasFlagEffectLabel,nil,id,e:GetLabel())
	if #g>0 then
		local reason_group=Group.CreateGroup()
		local phasect=Duel.IsEndPhase() and 2 or 1
		for tc in aux.Next(g) do
			tc:SetReason(tc:GetReason()|REASON_TEMPORARY)
			tc:RegisterFlagEffect(id+100,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,EFFECT_FLAG_CLIENT_HINT,phasect,0,STRING_TEMPORARILY_BANISHED)
			reason_group:AddCard(tc:GetReasonEffect():GetOwner())
		end
		for rc in aux.Next(reason_group) do
			local rg=g:Filter(s.retfilter,nil,rc)
			rg:KeepAlive()
			local e1=Effect.CreateEffect(rc)
			e1:SetDescription(STRING_RETURN_TO_FIELD)
			e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE|PHASE_END)
			e1:SetReset(RESET_PHASE|PHASE_END,phasect)
			e1:SetCountLimit(1)
			e1:SetLabel(Duel.GetTurnCount()+phasect-1)
			e1:SetLabelObject(rg)
			e1:SetCondition(aux.TimingCondition(PHASE_END,nil,false))
			e1:SetOperation(aux.ReturnLabelObjectToFieldOp(id+100))
			Duel.RegisterEffect(e1,tp)
		end
	end
	e:Reset()
end
function s.retfilter(c,rc)
	return c:GetReasonEffect():GetOwner()==rc
end