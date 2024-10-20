--[[
The Queen's Tactics
Le Tattiche della Regina
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[At the start of your opponent's Battle Phase, if you control an "Invernal" monster or a DARK "Number" Xyz Monster: Change all monsters your opponent controls to Attack Position.
	For the rest of this turn after this effect resolves, all monsters your opponent controls must attack (if able), also, at the start of each Damage Step in which a monster your
	opponent controls battles an "Invernal" monster you control, banish the top card of your opponent's Deck and 1 random card from your opponent's GY, both face-down.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:HOPT()
	e1:SetFunctions(
		aux.AND(aux.StartOfBattlePhaseCond(1),aux.LocationGroupCond(s.cfilter,LOCATION_MZONE,0,1)),
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--[[If this card is in your GY while you control a DARK "Number" Xyz Monster that has 2 or less materials: You can banish this card and any number of DARK monsters from your GY,
	then target 1 DARK "Number" Xyz Monster you control with 2 or less materials; attach, from your Extra Deck and/or GY, as many Fusion, Synchro, Xyz, Link, and/or Pendulum monsters
	to that target as possible, up to the number of monsters banished to activate this effect.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCustomCategory(CATEGORY_ATTACH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetRelevantTimings()
	e2:SHOPT()
	e2:SetFunctions(
		nil,
		aux.DummyCost,
		s.attg,
		s.atop
	)
	c:RegisterEffect(e2)
end

--E1
function s.cfilter(c)
	return c:IsFaceup() and (c:IsSetCard(ARCHE_INVERNAL) or (c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)))
end
function s.filter(c)
	return not c:IsAttackPos() and c:IsCanChangePosition()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetCardOperationInfo(g,CATEGORY_POSITION)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
	end
	local c=e:GetHandler()
	c:MustAttackField(tp,0,LOCATION_MZONE,nil,nil,RESET_PHASE|PHASE_END,c)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(s.rmcon)
	e3:SetOperation(s.rmop)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
	Duel.RegisterHint(tp,id,RESET_PHASE|PHASE_END,1,id,1,nil,e3)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local b1,b2=Duel.GetBattleMonster(tp),Duel.GetBattleMonster(1-tp)
	if not b1 or not b2 then return false end
	local g=Group.FromCards(b1,b2)
	return g:FilterCount(Card.IsRelateToBattle,nil)==#g and b1:IsFaceup() and b1:IsSetCard(ARCHE_INVERNAL)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetDecktopGroup(1-tp,1):Filter(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)
	local g2=Duel.GetGY(1-tp):Filter(Card.IsAbleToRemove,nil,tp,POS_FACEDOWN)
	if #g1*#g2==0 then return end
	Duel.Hint(HINT_CARD,tp,id)
	local rg2=g2:RandomSelect(tp,1)
	Duel.HintSelection(rg2)
	g1:Merge(rg2)
	Duel.DisableShuffleCheck(true)
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end

--E2
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK) and c:GetOverlayCount()<=2
end
function s.rmfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
function s.gcheck(g,e,tp,mg,c)
	local res=Duel.IsExists(true,s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,g)
	return res, not res
end
function s.atfilter(c,e,tp,xyzc)
	return c:IsType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK|TYPE_PENDULUM) and c:IsCanBeAttachedTo(xyzc,e,tp,REASON_EFFECT)
end
function s.xyzfilter(c,e,tp,g)
	return s.cfilter2(c) and Duel.IsExists(false,s.atfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,g,e,tp,c)
end

function s.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter2(chkc) end
	local c=e:GetHandler()
	local g=Duel.Group(s.rmfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then
		return e:IsCostChecked() and c:IsAbleToRemoveAsCost() and #g>0 and aux.SelectUnselectGroup(g,e,tp,1,1,s.gcheck,0)
	end
	local ct=0
	local rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.gcheck,1,tp,HINTMSG_REMOVE,s.gcheck)
	if Duel.Remove(rg+c,POS_FACEUP,REASON_COST)>0 then
		ct=Duel.GetGroupOperatedByThisCost(e):FilterCount(Card.IsContained,nil,rg)
	end
	Duel.SetTargetParam(ct)
	local tg=Duel.Select(HINTMSG_ATTACHTO,true,tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE,tg)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsControler(tp) and s.cfilter2(tc) then
		local ct=Duel.GetTargetParam()
		local g=Duel.Group(aux.Necro(s.atfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,nil,e,tp,tc)
		if #g==0 then return end
		ct=math.min(#g,ct)
		Duel.HintMessage(tp,HINTMSG_ATTACH)
		local tg=g:Select(tp,ct,ct,nil)
		if #tg>0 then
			Duel.ConfirmCards(1-tp,tg)
			Duel.Attach(tg,tc,false,e,tp,REASON_EFFECT)
		end
	end
end