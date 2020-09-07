--created & coded by Lyris
--フェイト・ヒーロー絶望のライトガイ
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep2(c,cid.mfilter,2,63,false,true)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(TIMINGS_CHECK_MONSTER)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.mfilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0xf7a) and (not sg or sg:FilterCount(aux.TRUE,c)==0 or sg:Filter(Card.IsLevelAbove,c,1):CheckWithSumGreater(Card.GetLevel,fc:GetLevel()-c:GetLevel()))
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #sg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Select(tp,1,e:GetHandler():GetMaterialCount(),nil)
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
end
