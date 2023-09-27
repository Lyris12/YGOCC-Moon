--Aircaster Nitrify
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,cost)
	return c:IsFaceup() and c:IsSpell(TYPE_EQUIP) and c:IsSetCard(ARCHE_AIRCASTER) and c:GetSequence()<5 and (not cost or c:IsAbleToGraveAsCost())
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,0,2,nil,false)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_SZONE,0,1,nil,true)
	end
	local g=Duel.Select(HINTMSG_TOGRAVE,false,1-tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil,true)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,2)
	local b2=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	if not opt then return end
	if opt==0 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif opt==1 then
		e:SetCategory(0)
		e:SetProperty(0)
	end
	e:SetLabel(opt)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=e:GetLabel()
	if opt==0 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	else
		local ct=math.min(3,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
		if ct==0 then return end
		local ac=ct==1 and ct or Duel.AnnounceNumberMinMax(tp,1,ct)
		Duel.SortDecktop(tp,tp,ac)
	end
end