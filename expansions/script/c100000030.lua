--Zerost Void
--Vuoto Zerost
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[Target 1 of your "Zerost Null" or "Zerost Emptiness" that is banished or in your GY; apply its effect that Fusion Summons a "Zerost" Fusion Monster, also shuffle it into your Deck.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY; the next time a player rolls a dice because of an activated card effect, you can increase or reduce the result of that die roll by 1.]]
	aux.AddZerostDiceModifier(c,id,EFFECT_TYPE_QUICK_O)
end
function s.filter(c,tp)
	if not (c:IsFaceupEx() and c:IsCode(100000027,100000029) and c:IsAbleToDeck()) then return false end
	local egroup=c:GetEffects()
	for _,te in ipairs(egroup) do
		if aux.GetValueType(te)=="Effect" and te:IsHasCategory(CATEGORY_FUSION_SUMMON) then
			local tg=te:GetTarget()
			if (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,te,REASON_EFFECT,PLAYER_NONE,0)) then
				return true
			end
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then
		return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TODECK,true,tp,s.filter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,tp)
	local tc=g:GetFirst()
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
	if tc then
		local egroup=tc:GetEffects()
		local te=nil
		local acd={}
		local ac={}
		for _,temp in ipairs(egroup) do
			if aux.GetValueType(temp)=="Effect" and temp:IsHasCategory(CATEGORY_FUSION_SUMMON) then
				local tg=temp:GetTarget()
				if (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,temp,REASON_EFFECT,PLAYER_NONE,0)) then
					table.insert(ac,temp)
					table.insert(acd,temp:GetDescription())
				end
			end
		end
		if #ac==1 then
			te=ac[1]
		elseif #ac>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			op=Duel.SelectOption(tp,table.unpack(acd))
			op=op+1
			te=ac[op]
		end
		if not te then return end
		Duel.ClearTargetCard()
		tc:CreateEffectRelation(e)
		e:SetLabelObject(tc)
		local tg=te:GetTarget()
		if tg then
			tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,te,REASON_EFFECT,PLAYER_NONE,1)
		end
		e:SetOperation(s.operation(te))
	end
end
function s.operation(te)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if aux.GetValueType(te)~="Effect" then return end
				e,tp,eg,ep,ev,re,r,rp = aux.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
				local tc=e:GetLabelObject()
				if tc:IsRelateToChain() then
					tc:CreateEffectRelation(te)
					Duel.BreakEffect()
					local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
					for etc in aux.Next(g) do
						etc:CreateEffectRelation(te)
					end
					local op=te:GetOperation()
					if op then
						op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,te,REASON_EFFECT,PLAYER_NONE,1)
					end
					tc:ReleaseEffectRelation(te)
					for etc in aux.Next(g) do
						etc:ReleaseEffectRelation(te)
					end
					Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
end