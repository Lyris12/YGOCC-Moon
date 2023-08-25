--Flibberty Schizmaspatleblap
--Rivelibbertà Schizmaspatleblap
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--[[When you activate this card, you can also discard 1 monster; Special Summon 1 Flip monster from your GY in face-down Defense Position,
	then, if you discarded a monster at activation, Special Summon 1 "Flibberty" monster from your Deck, with the same Attribute as the discarded monster, in face-up or face-down Defense Position.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(nil,s.cost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY, except the turn it was sent there: You can banish this card, then target 1 Set monster, or 1 "Flibberty" monster, you control;
	change it to face-up or face-down Defense Position.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(aux.exccon,aux.bfgcost,s.postg,s.posop)
	c:RegisterEffect(e2)
end
--FE1
function s.spfilter1(c,e,tp,check)
	return c:IsMonster(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and (check==0 or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c,e,tp,cc))
end
function s.cfilter(c,e,tp,cc)
	return c:IsMonster() and c:IsDiscardable() and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,Group.FromCards(c,cc),e,tp,c:GetAttribute())
end
function s.spfilter2(c,e,tp,attr)
	return c:IsSetCard(ARCHE_FLIBBERTY) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
function s.spfilter3(c,e,tp,check)
	return c:IsMonster(TYPE_FLIP) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and (check==0 or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,c,e,tp,check))
end
--E1
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,0)
	local b=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,1) and e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetMZoneCount(tp)>1 and Duel.IsPlayerCanSpecialSummonCount(tp,2) 
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and (a or b)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and b and Duel.SelectYesNo(tp,STRING_ASK_DISCARD) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,nil)
		local tc=Duel.GetOperatedGroup():GetFirst()
		e:SetLabel(tc:GetAttribute())
	else
		e:SetLabel(0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:IsCostChecked() or (Duel.GetMZoneCount(tp)>0 and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,0))
	end
	if not e:IsCostChecked() then
		e:SetLabel(0)
	end
	local ct,loc = 1,LOCATION_GRAVE
	if e:GetLabel()>0 then
		ct,loc = 2,loc|LOCATION_DECK
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,loc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local attr=e:GetLabel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter3),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,attr)
	if not g or #g<=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,aux.Necro(s.spfilter3),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,0)
	end
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		if Duel.GetMZoneCount(tp)<=0 or attr==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,attr)
		if #g2>0 then
			Duel.BreakEffect() 
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_DEFENSE)
			if g2:GetFirst():IsFacedown() then g:Merge(g2) end
		end
		Duel.ConfirmCards(1-tp,g)
	end
end

--FE2
function s.posfilter(c)
	if c:IsFaceup() or c:IsPosition(POS_FACEDOWN_ATTACK) then
		return (not c:IsFaceup() or c:IsSetCard(ARCHE_FLIBBERTY)) and c:IsCanTurnSetGlitchy()
	else
		return c:IsCanChangePosition()
	end
end
--E2
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.posfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.posfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_POSCHANGE,true,tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_POSITION)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		local pos=0
		if (tc:IsFaceup() or tc:IsPosition(POS_FACEDOWN_ATTACK)) and tc:IsCanTurnSetGlitchy() then
			pos=POS_FACEDOWN_DEFENSE
		elseif tc:IsFacedown() and tc:IsCanChangePosition() then
			pos=POS_FACEUP_DEFENSE
		end
		if pos==0 then return end
		Duel.ChangePosition(tc,pos)
	end
end