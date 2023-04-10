--Future-Eyes Superdimensional Dragon
local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Future-Eyes Superdimensional Dragon".
	c:SetUniqueOnField(1,0,id)
	aux.AddOrigTimeleapType(c,false)
	aux.AddTimeleapProc(c,8,s.sumcon,s.tlfilter)
	c:EnableReviveLimit()
	--Any monster destroyed by battle with this card is banished
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--Once per turn, when a card or effect is activated: You can banish this card. 
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--If this card is banished: You can activate this effect; during the End Phase of this turn Special Summon this card, and if you do, you can banish 1 card your opponent controls until the end of the next turn.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.spregtg)
	e3:SetOperation(s.spregop)
	c:RegisterEffect(e3)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetLabel(id)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.sumcon(e,c)
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),id)>0
end
function s.tlfilter(c,e,mg)
	local tp=c:GetControler()
	local ef=e:GetHandler():GetFuture()
	return c:IsLevelBelow(ef-1) and c:IsType(TYPE_EFFECT)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Remove(c,POS_FACEUP,REASON_EFFECT)
	end
end
function s.spregtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spregop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(Duel.GetTurnCount())
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_CARD,0,id)
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
			if #g>0 then 
				tc=g:GetFirst()
				if Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
				tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,1))
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				e1:SetLabelObject(tc)
				e1:SetCountLimit(1)
				e1:SetCondition(s.retcon)
				e1:SetOperation(s.retop)
				e1:SetLabel(Duel.GetTurnCount())
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local i=0
	if global_duel_effect_table[tp] then
		for key,value in pairs(global_duel_effect_table[tp]) do
			if (value:GetCode()&EVENT_PHASE)~=0 and not (value:GetCode()&PHASE_MAIN1)~=0 and not (value:GetCode()&PHASE_MAIN2)~=0 and value:GetHandler()==re:GetHandler() then
				--Debug.Message(value:GetHandler())
				--Debug.Message(re:GetHandler())
				i=i+1
			end
		end
	end
	if global_duel_effect_table[1-tp] then
		for key,value in pairs(global_duel_effect_table[1-tp]) do
			if (value:GetCode()&EVENT_PHASE)~=0 and not (value:GetCode()&PHASE_MAIN1)~=0 and not (value:GetCode()&PHASE_MAIN2)~=0 and value:GetHandler()==re:GetHandler() then
				--Debug.Message(value:GetHandler())
				--Debug.Message(re:GetHandler())
				i=i+1
			end
		end
	end
	return i>0 and Duel.IsMainPhase()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	Duel.RegisterFlagEffect(1-tp,id,RESET_PHASE+PHASE_END,0,1)
end
