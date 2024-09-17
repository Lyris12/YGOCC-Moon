--Geneseed Cherry Tiger
local cid,id=GetID()
function cid.initial_effect(c)
c:EnableReviveLimit()
   aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,1)
	   aux.AddOrigEvoluteType(c)
	 aux.AddEvoluteProc(c,nil,7,aux.AND(cid.filter1,cid.filter1),2,99)  
	--discard deck & draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.drcost)
	e1:SetTarget(cid.drtg)
	e1:SetOperation(cid.drop)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(cid.atkval)
	c:RegisterEffect(e2)
	
end

function cid.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,3,REASON_COST) end
	e:GetHandler():RemoveEC(tp,3,REASON_COST)
end
function cid.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return (chkc:IsOnField() or chkc:IsLocation(LOCATION_GRAVE)) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	
end
function cid.drop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	  local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and e:GetHandler():GetOverlayCount()==0 then
	Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
 local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)  
else
Duel.Overlay(c,Group.FromCards(tc))
		  local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)  
	end
end
function cid.filter1(c,ec,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsType(TYPE_EFFECT)
end

function cid.atkfilter(c)
	return  c:GetAttack()>=0
end
function cid.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(cid.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
