--Dracosis Syowar

local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,s.mfilter,s.xyzcheck,2,2,s.alt,aux.Stringid(id,0))
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--xyz material
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(2,id+EFFECT_COUNT_CODE_OATH)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(aux.DetachSelfCost())
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
function s.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,4) and c:IsSetCard(0x300)
end
function s.xyzcheck(g)
	return g:GetClassCount(Card.GetRace)==#g or g:GetClassCount(Card.GetAttribute)==#g
end
function s.alt(c,xyzc)
	return c:IsXyzType(TYPE_MONSTER) and c:IsXyzLevel(xyzc,6) and c:IsSetCard(0x300)
end

function s.atkval(e)
	local g=e:GetHandler():GetOverlayGroup()
	if #g<=0 then return 0 end
	local ct1=g:GetSum(Card.GetOriginalLevel)+g:GetSum(Card.GetOriginalRank)
	local ct2=g:GetSum(Card.GetLink)
	return (ct1*100)+(ct2*200)
end

function s.atfilter(c)
	return c:IsMonster() and c:IsCanOverlay()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsInGY() and s.atfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.atfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	local g=Duel.SelectTarget(tp,s.atfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_LEAVE_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsMonster(TYPE_XYZ) and c:IsRelateToChain() and tc:IsRelateToChain() then
		Duel.Attach(tc,c)
	end
end
