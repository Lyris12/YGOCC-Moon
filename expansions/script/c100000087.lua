--Trappit Designer
--Trappolaniglio Progettista
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[If a monster(s) is Normal or Flip Summoned (Quick Effect): You can discard this card and reveal 1 "Trappit" card in your hand or that is Set on your field, except "Trappit Designer";
	send from your hand or Deck to the GY, 1 Normal Trap that activates when a monster is Normal or Flip Summoned, or Normal Set, and if you do, destroy 1 of those monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOGRAVE|CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CUSTOM+id+1)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCondition(s.evcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--[[If this card or another monster(s) is Normal or Flip Summoned (except during the Damage Step): You can add 1 "Trappit" monster from your Deck to your hand, then, immediately after this effect resolves, Normal Summon/Set 1 monster from your hand (if you can).]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_SUMMON)
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
	if not s.global_check then
		s.global_check=true
		aux.RegisterMergedDelayedEventGlitchy(c,id,{EVENT_SUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS},aux.TRUE,id)
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CUSTOM+id)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentPhase()==PHASE_DAMAGE then return false end
	local v=0
	if eg:IsExists(Card.IsSummonPlayer,1,nil,0) then v=v+1 end
	if eg:IsExists(Card.IsSummonPlayer,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(eg,EVENT_CUSTOM+id+1,re,r,rp,ep,e:GetLabel())
end

function s.evcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
function s.rvfilter(c)
	return c:IsSetCard(ARCHE_TRAPPIT) and not c:IsCode(id) and ((c:IsOnField() and c:IsFacedown()) or (c:IsLocation(LOCATION_HAND) and not c:IsPublic()))
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
function s.filter(c)
	if not c:IsNormalTrap() or not c:IsAbleToGrave() then return false end
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetTargetCard(eg)
	Duel.SetCardOperationInfo(eg,CATEGORY_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and aux.PLChk(g,tp,LOCATION_GRAVE) then
		local tg=Duel.GetTargetCards()
		if #tg>0 then
			local sg=tg:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end

function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_TRAPPIT) and c:IsAbleToHand()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g,tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=Duel.SelectMatchingCard(tp,Card.IsSummonableOrSettable,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
		if #sg>0 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			Duel.SummonOrSet(tp,sg:GetFirst())
		end
	end
end