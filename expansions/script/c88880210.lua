--Mecha Blade Recruiter
local m=88880210
local cm=_G["c"..m]
function cm.initial_effect(c)
	aux.AddXyzProcedure(c,cm.mfilter,4,2,cm.ovfilter,aux.Stringid(m,0),2,cm.xyzop)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,88881210)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(cm.cost)
	e1:SetTarget(cm.athtg)
	e1:SetOperation(cm.athop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,88883210)
	e2:SetTarget(cm.target)
	e2:SetOperation(cm.operation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,88883210)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cm.tfcon)
	e3:SetTarget(cm.target)
	e3:SetOperation(cm.operation)
	c:RegisterEffect(e3)
end

--filters

function c88880210.mfilter(c)
	return c:IsSetCard(0xffd)
end
function c88880210.ovfilter(c)
	return c:IsFaceup()
		and ((c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,88880005))
		or (c:IsCode(88880006) and c:GetOverlayGroup():GetCount()>0))
end
function c88880210.xyzop(e,tp,chk,mc)
	if chk==0 then return mc:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	mc:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function cm.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end

--add to hand

function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

function cm.athtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_OVERLAY)
end

function cm.athop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=0
		or not Duel.IsExistingMatchingCard(cm.xyzfilter,tp,LOCATION_MZONE,0,1,nil) then 
			return 
	end
	local td=Duel.GetDecktopGroup(tp,0)
	local check=0
	Duel.Overlay(e:GetHandler(),td)
	for tc in aux.Next(td) do
		if e:GetHandler():GetOverlayGroup():IsContains(tc) then
			check=check+1
		end
	end
	if check>=0 then
		local g=Group.CreateGroup()
		g:KeepAlive()
		local xg=Duel.GetMatchingGroup(cm.xyzfilter,tp,LOCATION_MZONE,0,nil)
		for xc in aux.Next(xg) do
			g:Merge(xc:GetOverlayGroup():Filter(Card.IsAbleToHand,nil))
		end
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tg=g:Select(tp,1,1,nil)
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tg)
		end
		g:DeleteGroup()
	end
end



--3

--eff 3 filters
function cm.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xffd)
end

function cm.filter3(c)
	return c:IsSetCard(0xffd) and c:IsType(TYPE_MONSTER)
end

function cm.tfcfilter(c,tp)
	return c:IsSetCard(0xffd) and c:IsPreviousLocation(LOCATION_OVERLAY) and c:GetPreviousControler()==tp
end
-- eff 3 components

function cm.tfcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.tfcfilter,1,nil,tp)
end


function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cm.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(cm.filter3,tp,LOCATION_DECK,0,1,nil,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cm.filter,tp,LOCATION_MZONE,0,1,1,nil)
end

function cm.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,cm.filter3,tp,LOCATION_DECK,0,1,1,nil,nil)
		if g:GetCount()>0 then end
			Duel.Overlay(tc,g)
		end