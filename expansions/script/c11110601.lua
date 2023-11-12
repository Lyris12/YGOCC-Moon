--Kuppar, Metalurgos Courier
--Kuppar, Metalurgo Corriere
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,6)
	--[[▼ [-3]: You can target 1 "Metalurgos" monster you control and 1 "Metalurgos" Continuous Spell in your GY;
	shuffle the second target into the Deck, and if you do, the first target gains either 500 ATK or DEF.]]
	c:DriveEffect(-3,0,CATEGORY_TODECK|CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.tdtg,
		s.tdop
	)
	--[[[OD]: (Quick Effect): You can place 1 "Metalurgos" Continuous Spell from your GY face-up in your Spell & Trap Zone.]]
	c:OverDriveEffect(3,nil,EFFECT_TYPE_QUICK_O,nil,nil,
		nil,
		nil,
		s.pctg,
		s.pcop
	)
	--[[If this card is Normal Summoned: You can destroy 1 "Metalurgos" Continuous Spell in your Deck, then you can reduce the Energy of your Engaged "Metalurgos" Drive Monster to 1.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(4)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCustomCategory(CATEGORY_CHANGE_ENERGY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:HOPT()
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--[[If this card is destroyed by a card effect, OR as Bigbang Material:
	You can destroy 1 "Metalurgos" Continuous Spell you control, and if you do, Special Summon this card from your GY, but shuffle it into the Deck when it leaves the field.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(6)
	e2:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:HOPT()
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
--FILTERS DE1
function s.statfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_METALURGOS) and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,c)
end
function s.tdfilter(c)
	return c:IsSetCard(ARCHE_METALURGOS) and c:IsSpell(TYPE_CONTINUOUS) and c:IsAbleToDeck()
end
--DE1
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingTarget(s.statfilter,tp,LOCATION_MZONE,0,1,nil,tp)
	end	
	local g1=Duel.Select(HINTMSG_FACEUP,true,tp,s.statfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	local g2=Duel.Select(HINTMSG_TODECK,true,tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,g1)
	if #g2>0 then
		g2:GetFirst():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
		Duel.SetCardOperationInfo(g2,CATEGORY_TODECK)
	end
	g1:Merge(g2)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g==0 then return end
	local tc2=g:Filter(Card.HasFlagEffect,nil,id):GetFirst()
	if tc2 and s.tdfilter(tc2) then
		g:RemoveCard(tc2)
		if Duel.ShuffleIntoDeck(tc2)>0 and #g>0 then
			local tc1=g:GetFirst()
			if tc1 and tc1:IsFaceup() and tc1:IsSetCard(ARCHE_METALURGOS) then
				local opt=aux.Option(tp,id,1,tc1:HasAttack(),tc1:HasDefense())
				if not opt then return end
				local ecode = opt==0 and EFFECT_UPDATE_ATTACK or EFFECT_UPDATE_DEFENSE
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(ecode)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				e1:SetValue(500)
				tc1:RegisterEffect(e1)
			end
		end
	end
end

--FILTERS DE2
function s.pcfilter(c,tp)
	return c:IsSetCard(ARCHE_METALURGOS) and c:IsSpell(TYPE_CONTINUOUS) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
--DE2
function s.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.pcfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.pcop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.pcfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp)
	if #g>0 then 
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end

--FILTERS ME1
function s.desfilter(c,e)
	return c:IsSetCard(ARCHE_METALURGOS) and c:IsSpell(TYPE_CONTINUOUS) and (not e or c:IsDestructable(e))
end
--ME1
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_DECK,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleCustomOperationInfo(0,CATEGORY_CHANGE_ENERGY,nil,1,0,1)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.Destroy(g:GetFirst(),REASON_EFFECT)>0 then
		local c=e:GetHandler()
		local ec=Duel.GetEngagedCard(tp)
		if ec and ec:IsMonster(TYPE_DRIVE) and ec:IsSetCard(ARCHE_METALURGOS) and ec:IsCanChangeEnergy(1,tp,REASON_EFFECT) and c:AskPlayer(tp,5) then
			Duel.BreakEffect()
			ec:ChangeEnergy(1,tp,REASON_EFFECT,true,c)
		end
	end
end

--FILTERS ME2
function s.dcfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(ARCHE_METALURGOS) and c:IsSpell(TYPE_CONTINUOUS) and Duel.GetMZoneCount(tp,c)>0
end
--ME2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) or c:GetReason()&(REASON_MATERIAL|REASON_BIGBANG)==REASON_MATERIAL|REASON_BIGBANG
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.dcfilter,tp,LOCATION_ONFIELD,nil,tp)
	if chk==0 then
		return #g>0 and c:IsLocation(LOCATION_GRAVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_ONFIELD)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_DESTROY,false,tp,s.dcfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 and not c:IsHasEffect(EFFECT_NECRO_VALLEY) then
			Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP,nil,LOCATION_DECKSHF)
		end
	end
end