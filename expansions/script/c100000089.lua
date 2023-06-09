--Trappit Mapper
--Trappolaniglio Mappatore
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[(Quick Effect): You can discard this card and reveal 1 "Trappit" card in your hand, or that is Set on your field, except "Trappit Mapper";
	add from your Deck to your hand, 1 Normal Trap with an effect that activates when a monster is Normal or Flip Summoned,
	then you can return any number of Set cards from your Spell & Trap Zone to the hand, and if you do, Set any number of Spells/Traps from your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--[[If this card, or another monster(s) (except during the Damage Step), is Normal or Flip Summoned, you can:
	Immediately after this effect resolves, Normal Set 1 monster from your hand, and if you do, if you control another "Trappit" card,
	you can look at the top cards of your Deck, equal to the number of Set cards you control, and place them on the top of your Deck in any order.]]
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
	e2y:SetCondition(s.condition)
	c:RegisterEffect(e2y)
	local e2z=e2y:FlipSummonEventClone(c)
end
--Filters E1
function s.rvfilter(c)
	return c:IsSetCard(ARCHE_TRAPPIT) and not c:IsCode(id) and ((c:IsOnField() and c:IsFacedown()) or (c:IsLocation(LOCATION_HAND) and not c:IsPublic()))
end
function s.thfilter(c)
	if not c:IsNormalTrap() or not c:IsAbleToHand() then return false end
	local egroup=c:GetEffects()
	local res=false
	for i,e in ipairs(egroup) do
		if e and not e:WasReset(c) then
			if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
				local event=e:GetCode()
				if (event==EVENT_SUMMON_SUCCESS or event==EVENT_FLIP_SUMMON_SUCCESS) or e:IsHasCustomCategory(CATEGORY_ACTIVATES_ON_NORMAL_SET) then
					res=true
					break
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
function s.bcfilter(c)
	return c:GetSequence()<5 and c:IsFacedown() and c:IsAbleToHand()
end
function s.setfilter(c)
	return c:IsST() and c:IsSSetable(true)
end
function s.gcheck(g,c,G,f,min,max,ext_params)
	local ft=ext_params[1]
	return ft>=g:FilterCount(s.notfield,nil) and g:FilterCount(Card.IsType,nil,TYPE_FIELD)<=1
end
function s.notfield(c)
	return not c:IsType(TYPE_FIELD)
end
--Text sections E1
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
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local ct,hct=Duel.Search(g,tp)
		if ct>0 and hct>0 then
			local c=e:GetHandler()
			local sg=Duel.Group(s.bcfilter,tp,LOCATION_SZONE,0,nil)
			if #sg>0 and c:AskPlayer(tp,2) then
				Duel.ShuffleHand(tp)
				local tg=sg:Select(tp,1,#sg,nil)
				if #tg>0 then
					Duel.HintSelection(tg)
					Duel.BreakEffect()
					local ct,hct=Duel.Bounce(tg)
					if ct>0 and hct>0 then
						local setg=Duel.Group(s.setfilter,tp,LOCATION_HAND,0,nil)
						local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
						aux.GCheckAdditional=s.gcheck
						local res=setg:CheckSubGroup(aux.TRUE,1,#setg,ft)
						aux.GCheckAdditional=nil
						if res and c:AskPlayer(tp,3) then
							Duel.ShuffleHand(tp)
							aux.GCheckAdditional=s.gcheck
							local stg=setg:SelectSubGroup(tp,aux.TRUE,false,1,#setg,ft)
							aux.GCheckAdditional=nil
							if #stg>0 then
								Duel.SSet(tp,stg)
							end
						end
					end
				end
			end
		end
	end
end

--Text sections E2
function s.condition(e,tp,eg,ep,ev,re,r,rp)
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
	if oeg:IsContains(oe:GetLabelObject()) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_TRAPPIT),tp,LOCATION_ONFIELD,0,1,c) then
		local ct=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_ONFIELD,0,nil)
		if ct>0 and Duel.GetDeckCount(tp)>=ct and c:AskPlayer(tp,4) then
			Duel.SortDecktop(tp,tp,ct)
		end
	end
end					