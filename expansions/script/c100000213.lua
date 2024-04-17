--[[
Eternadir Confrontation
Scontro Eternadir
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:Activation(false,true)
	--[[During either player's turn: You can return 1 "Eternadir" Pendulum Monster Card you control to the hand, and if you do, place 1 "Eternadir" Pendulum Monster from your hand in your Pendulum Zone.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--[[If this face-up card leaves the field by an opponent's card effect: You can Tribute 1 "Eternadir" Monster Card from your hand or field; destroy all face-up monsters your opponent controls]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:HOPT()
	e2:SetFunctions(s.descon,s.descost,s.destg,s.desop)
	c:RegisterEffect(e2)
end

--E1
function s.thfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_ETERNADIR) and c:IsPendulumMonsterCard() and c:IsAbleToHand()
		and (Duel.CheckPendulumZones(tp) or c:IsLocation(LOCATION_PZONE))
end
function s.penfilter(c)
	return c:IsSetCard(ARCHE_ETERNADIR) and c:IsMonster(TYPE_PENDULUM) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_PZONE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_RTOHAND,false,tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.SearchAndCheck(g) then
			Duel.ShuffleHand(g:GetFirst():GetControler())
			local pg=Duel.Select(HINTMSG_TOFIELD,false,tp,s.penfilter,tp,LOCATION_HAND,0,1,1,nil)
			local tc=pg:GetFirst()
			if tc then
				Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
			end
		end
	end
end

--E2
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK) and c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp
end
function s.costfilter(c)
	return c:IsSetCard(ARCHE_ETERNADIR) and c:IsMonsterCard() and (c:IsControler(tp) or c:IsFaceup())
end
function s.excostfilter(c)
	return c:IsSetCard(ARCHE_ETERNADIR) and c:IsMonsterCard() and c:IsReleasable()
end
function s.fselect(g,tp,exg)
	local dg=g:Clone()
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,dg) then
		if #exg>0 and exg:IsContains(g:GetFirst()) then
			return true
		else
			Duel.SetSelectedCard(g)
			return Duel.CheckReleaseGroupEx(tp,nil,1,REASON_COST,true,nil)
		end
	else
		return false
	end
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g1=Duel.GetReleaseGroup(tp,true):Filter(s.costfilter,nil,tp)
	local g2=Duel.Group(s.excostfilter,tp,LOCATION_SZONE,0,1,nil)
	local exg=g2:Clone()
	g1:Merge(g2)
	if chk==0 then return g1:CheckSubGroup(s.fselect,1,1,tp,exg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=g1:SelectSubGroup(tp,s.fselect,false,1,1,tp,exg)
	aux.UseExtraReleaseCount(rg,tp)
	Duel.Release(rg,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() or Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	Duel.SetCardOperationInfo(sg,CATEGORY_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end