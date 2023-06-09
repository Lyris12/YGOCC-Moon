--Trappit Tester
--Trappolaniglio Collaudatore
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[● If your opponent controls a Special Summoned monster, you can activate this effect during their turn as well.
	During your turn (Quick Effect): You can discard this card and reveal 1 "Trappit" card in your hand, or that is Set on your field, except "Trappit Tester"; take control of 1 Normal Summoned/Set monster your opponent controls, until the end of the turn.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetHintTiming(0,RELEVANT_TIMINGS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--[[If this card, or another monster(s) (in which case, except during the Damage Step), is Normal or Flip Summoned, you can:
	Immediately after this effect resolves, Normal Set 1 monster from your hand, and if you do, and you control another "Trappit" card,
	you can Set 1 Normal Trap from your GY, but banish it when it leaves the field.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(aux.ExceptOnDamageStep)
	e2:SetTarget(s.nstg)
	e2:SetOperation(s.nsop)
	c:RegisterEffect(e2)
	local e2x=e2:FlipSummonEventClone(c)
	local e2y=e2:Clone()
	e2y:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2y:SetRange(LOCATION_MZONE)
	e2y:SetCondition(s.exccon)
	c:RegisterEffect(e2y)
	local e2z=e2y:FlipSummonEventClone(c)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	aux.TrappitNormalSummonCheck[tp] = Duel.IsExistingMatchingCard(Card.IsSummonable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,true,nil)	
end

--Filters E1
function s.rvfilter(c)
	return c:IsSetCard(ARCHE_TRAPPIT) and not c:IsCode(id) and ((c:IsOnField() and c:IsFacedown()) or (c:IsLocation(LOCATION_HAND) and not c:IsPublic()))
end
function s.filter(c)
	return c:IsControlerCanBeChanged() and c:IsSummonType(SUMMON_TYPE_NORMAL)
end
--Text sections E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp or Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsDiscardable() and Duel.IsExistingMatchingCard(s.rvfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,c)
	end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
	local g=Duel.Select(HINTMSG_CONFIRM,false,tp,s.rvfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,c)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end

--Filters E2
function s.setfilter(c)
	return c:IsNormalTrap() and c:IsSSetable()
end
--Text sections E2
function s.exccon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsMSetable,tp,LOCATION_HAND,0,1,nil,true,nil) end
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,Card.IsMSetable,tp,LOCATION_HAND,0,1,1,nil,true,nil)
	local tc=g:GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_MSET)
		e1:SetLabelObject(tc)
		e1:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
			s.tdop(e,tp,eg,ep,ev,re,r,rp,_e,_eg)
			_e:Reset()
		end
		)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,0)
		Duel.MSet(tp,tc,true,nil)
	end
end
function s.tdfilter(c)
	return c:IsNormalTrap() and c:IsAbleToDeck()
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp,oe,oeg)
	local c=e:GetHandler()
	if oeg:IsContains(oe:GetLabelObject()) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_TRAPPIT),tp,LOCATION_ONFIELD,0,1,c)
	and Duel.IsExistingMatchingCard(aux.Necro(s.setfilter),tp,LOCATION_GRAVE,0,1,nil) and c:AskPlayer(tp,2) then
		local g=Duel.Select(HINTMSG_SET,false,tp,aux.Necro(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			local tc=g:GetFirst()
			if Duel.SSet(tp,tc)>0 and tc:IsLocation(LOCATION_SZONE) and tc:IsFacedown() then
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(STRING_BANISH_REDIRECT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_CLIENT_HINT|EFFECT_FLAG_SET_AVAILABLE)
				e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
				e1:SetReset(RESET_EVENT|RESETS_REDIRECT_FIELD)
				e1:SetValue(LOCATION_REMOVED)
				tc:RegisterEffect(e1,true)
			end
		end
	end
end