--Assassinio da Soletluna
--Script by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(aux.exccon)
	e2:SetTarget(s.drawtg)
	e2:SetOperation(s.drawop)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=Duel.GetEngagedCard(tp)
	if chk==0 then
		return dc and dc:IsMonster() and dc:IsSetCard(0x209) and dc:IsCanUpdateEnergy(-3,tp,REASON_COST)
	end
	dc:UpdateEnergy(-3,tp,REASON_COST,true,e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then
		return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
	end
	local g=Duel.Select(HINTMSG_FACEUP,true,tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToDeck()
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c,nil,REASON_EFFECT)>0 then
		local attg=Duel.GetMatchingGroup(aux.Faceup(Card.IsSetCard),tp,LOCATION_MZONE,0,nil,0x209)
		if #attg==0 then return end
		local ct=attg:GetClassCount(Card.GetAttribute)
		if ct>0 and Duel.IsPlayerCanDraw(tp,ct) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Draw(tp,ct,REASON_EFFECT)
		end
	end
end