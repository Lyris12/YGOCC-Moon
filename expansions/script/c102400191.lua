--created & coded by Lyris, art by Nardack
--フェイト・ヒーローカオス・ゴッデス
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcMixRep(c,false,true,cid.mfilter0,0,63,cid.mfilter1,cid.mfilter2)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetTarget(cid.target)
	e2:SetOperation(cid.activate)
	c:RegisterEffect(e2)
end
function cid.mfilter0(c,fc,sub,mg,sg)
	return (c:IsFusionSetCard(0xf7a) or c:GetLevel()==0) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.mfilter1(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0xf7a) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.mfilter2(c,fc,sub,mg,sg)
	return c:GetLevel()==0
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,e:GetHandler():GetMaterialCount(),nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e),POS_FACEUP,REASON_EFFECT)
end
