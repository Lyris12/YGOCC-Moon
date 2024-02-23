--[[
Zerost Larva Zerotl
Larva Zerost Zerotl
Card Author: TopHatPenguin
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is Normal or Special Summoned: You can roll a six-sided die, and if you do, immediately after this effect resolves,
	Normal Summon 1 Level 6 "Zerost" monster with ATK/DEF equal to the result x 400, and if you do that, apply its effect that activates when it is banished by the effect of a "Zerost" card.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SUMMON|CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	e1:SpecialSummonEventClone(c)
	--[[If a "Zerost" card(s) you control would be destroyed by battle or card effect, you can banish this card from your field or GY instead.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE|LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	--[[If this card is banished by the effect of a "Zerost" card: You can send the top 3 cards of your Deck to the GY.]]
	aux.AddZerostMonsterEffects(c,CATEGORY_DECKDES,nil,s.tgtg,s.tgop,true)
end
--E1
function s.filter(c)
	return c:IsSetCard(ARCHE_ZEROST) and c:IsLevel(6) and c:IsSummonable(true,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dc=Duel.TossDice(tp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
		e1:SetProperty(EFFECT_FLAG_DELAY)
		e1:SetCode(EVENT_SUMMON_SUCCESS)
		e1:SetTarget(s.applytg)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
		tc:RegisterEffect(e1,true)
		aux.GainEffectType(tc,c,RESET_EVENT|RESETS_STANDARD_TOFIELD)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetValue(dc*400)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD_TOFIELD)
		tc:RegisterEffect(e2,true)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e3,true)
		Duel.Summon(tp,tc,true,nil)
	end
end

function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	e:SetCostCheck(false)
	if chk==0 then
		return s.checkeffect(c,tp,e)
	end
	e:SetProperty(EFFECT_FLAG_DELAY)
	local egroup=c:GetEffects()
	local te=nil
	local acd={}
	local ac={}
	for _,teh in ipairs(egroup) do
		if aux.GetValueType(teh)=="Effect" and teh:GetCode()==CARD_ZEROST_BEAST_ZEROTL then
			local temp=teh:GetLabelObject()
			if aux.GetValueType(temp)=="Effect" then
				local tg=temp:GetTarget()
				Duel.SetProxyEffect(e,temp)
				if (not tg or tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
					table.insert(ac,teh)
					table.insert(acd,temp:GetDescription())
				end
				Duel.ResetProxyEffect()
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
	local teh=te
	te=teh:GetLabelObject()
	Duel.ClearTargetCard()
	local tprop1,tprop2=te:GetProperty()
	e:SetProperty(tprop1,tprop2)
	
	local tg=te:GetTarget()
	if tg then
		Duel.SetProxyEffect(e,te)
		tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1)
		Duel.ResetProxyEffect()
	end
	
	e:SetOperation(s.applyop(te,teh))
end
function s.applyop(te,teh)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if aux.GetValueType(te)~="Effect" then return end
				e,tp,eg,ep,ev,re,r,rp = aux.OperationRegistrationProcedure(e,tp,eg,ep,ev,re,r,rp)
				e:SetCostCheck(false)
				local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
				if g then
					for etc in aux.Next(g) do
						etc:CreateEffectRelation(e)
					end
				end
				local op=te:GetOperation()
				if op then
					Duel.SetProxyEffect(e,te)
					op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1)
					Duel.ResetProxyEffect()
				end
				if g then
					for etc in aux.Next(g) do
						etc:ReleaseEffectRelation(e)
					end
				end
				e:SetProperty(EFFECT_FLAG_DELAY)
			end
end
	
function s.checkeffect(c,tp,e)
	local egroup=c:GetEffects()
	for i,teh in ipairs(egroup) do
		if aux.GetValueType(teh)=="Effect" and not teh:WasReset() then
			if teh:GetCode()==CARD_ZEROST_BEAST_ZEROTL then
				local te=teh:GetLabelObject()
				if aux.GetValueType(te)=="Effect" then
					local tg=te:GetTarget()
					Duel.SetProxyEffect(e,te)
					if (not tg or tg(e,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
						Duel.ResetProxyEffect()
						return true
					end
					Duel.ResetProxyEffect()
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return false
end

--E2
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsOnField()
		and c:IsSetCard(ARCHE_ZEROST) and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp) and c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE)
end

--E3
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end