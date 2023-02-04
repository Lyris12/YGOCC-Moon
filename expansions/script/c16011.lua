--Paracyclisity Devour Queen, Mantiscythe

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x308),2,2)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:HOPT(true)
	e1:SetCondition(s.condition)
	e1:SetCost(aux.LabelCost2)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--change position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:HOPT(true)
	e2:SetCost(s.poscost)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local l1,l2=e:GetLabel()
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsDestructable,nil)
	local bool
	if g:IsExists(Card.IsControler,1,nil,tp) then bool=true end
	if chk==0 then
		if l1~=1 then return false end
		e:SetLabel(0,l2)
		return #g>0 and (not bool or Duel.IsPlayerCanDraw(tp,1))
	end
	e:SetLabel(0,l2)
	if Duel.Destroy(g,REASON_COST)>0 then
		if Duel.GetOperatedGroup():IsExists(Card.IsPreviousControler,1,nil,tp) then
			e:SetCategory(CATEGORY_DRAW)
			e:SetProperty(EFFECT_FLAG_DDD+EFFECT_FLAG_PLAYER_TARGET)
			Duel.SetTargetPlayer(tp)
			Duel.SetTargetParam(1)
			e:SetLabel(l1,1)
			Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		else
			e:SetCategory(0)
			e:SetProperty(EFFECT_FLAG_DDD)
			e:SetLabel(l1,0)
		end
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local _,lab=e:GetLabel()
	if lab==1 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	end	
end

function s.cfilter(c)
	return c:IsSetCard(0x308) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,nil,REASON_COST)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanTurnSetGlitchy(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSITION)
	local g=Duel.SelectTarget(tp,Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,1,2,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,1-tp,LOCATION_MZONE)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g<=0 then return end
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:Desc(2)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.limcon)
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		end
		e1:SetLabel(Duel.GetTurnCount(),tp)
		tc:RegisterEffect(e1)
	end
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end