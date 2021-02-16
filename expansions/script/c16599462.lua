--Arbitrium dell'Organizzazione Angeli
--Script by XGlitchy30
function c16599462.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16599462,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c16599462.cost)
	e1:SetTarget(c16599462.target)
	e1:SetOperation(c16599462.activate)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetDescription(aux.Stringid(16599462,1))
	e1x:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1x:SetType(EFFECT_TYPE_ACTIVATE)
	e1x:SetCode(EVENT_FREE_CHAIN)
	e1x:SetCost(c16599462.cost)
	e1x:SetTarget(c16599462.target2)
	e1x:SetOperation(c16599462.activate2)
	c:RegisterEffect(e1x)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,16599462)
	e2:SetCondition(aux.exccon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c16599462.drawtg)
	e2:SetOperation(c16599462.drawop)
	c:RegisterEffect(e2)
	--act in hand
	local hand=Effect.CreateEffect(c)
	hand:SetType(EFFECT_TYPE_SINGLE)
	hand:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	hand:SetCondition(c16599462.quickact)
	c:RegisterEffect(hand)
end
--filters
function c16599462.cfilter(c,tp)
	return c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:GetLevel()>0
		and Duel.IsExistingTarget(c16599462.lvexc,tp,LOCATION_MZONE,0,1,c,c:GetLevel())
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
		and c:IsAbleToRemoveAsCost()
end
function c16599462.cfilter2(c,e,tp)
	return c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:GetLevel()>0
		and Duel.IsExistingMatchingCard(c16599462.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
		and (c:IsLocation(LOCATION_DECK+LOCATION_GRAVE) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup()))
		and c:IsAbleToRemoveAsCost()
end
function c16599462.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetLevel()~=lv
end
function c16599462.lvexc(c,lv)
	return c:IsFaceup() and c:GetLevel()>0 and c:GetLevel()~=lv
end
function c16599462.tdfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1559) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
--Activate
function c16599462.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c16599462.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c16599462.lvexc(chkc,e:GetLabelObject():GetLevel()) end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c16599462.cfilter,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) 
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599462.cfilter,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		local op=Duel.GetOperatedGroup():GetFirst()
		e:SetLabelObject(op)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,c16599462.lvexc,tp,LOCATION_MZONE,0,1,1,nil,e:GetLabelObject():GetLevel())
	end
end
function c16599462.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local lv,def=e:GetLabelObject():GetLevel(),e:GetLabelObject():GetDefense()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
		if def>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(def)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
function c16599462.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c16599462.cfilter2,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c16599462.cfilter2,tp,LOCATION_DECK+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
		local op=Duel.GetOperatedGroup():GetFirst()
		e:SetLabelObject(op)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	end
end
function c16599462.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabelObject():GetLevel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c16599462.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			g:GetFirst():RegisterEffect(e1)
			if not g:GetFirst():IsSetCard(0x1559) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				g:GetFirst():RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				g:GetFirst():RegisterEffect(e2)
			end
		end
		Duel.SpecialSummonComplete()
	end
end
--draw
function c16599462.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsExistingMatchingCard(c16599462.tdfilter,tp,LOCATION_REMOVED,0,2,nil)
	end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c16599462.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local ct=Duel.Draw(p,d,REASON_EFFECT)
	if ct~=0 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,c16599462.tdfilter,tp,LOCATION_REMOVED,0,2,2,nil)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end
--act in hand
function c16599462.quickact(e)
	local tp=e:GetHandler():GetControler()
	return Duel.GetTurnPlayer()==tp and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)+1
end