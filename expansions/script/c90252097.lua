--Pandemoniumgraph of Armageddon
local cid,id=GetID()
function cid.initial_effect(c)
	--You can only control 1 face-up "Pandemoniumgraph of Armageddon".
	c:SetUniqueOnField(1,0,id)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	c:RegisterEffect(e1)
	--Your opponent cannot target Pandemonium Monsters you control with Trap effects.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsType(TYPE_PANDEMONIUM) end)
	e2:SetValue(cid.evalue)
	c:RegisterEffect(e2)
	--Once per turn, you can target 1 card in your Pandemonium Zone and 1 monster your opponent controls; destroy them. You must control a face-up Pandemonium card in your Pandemonium zone to activate this effect.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetHintTiming(0,0x1e0)
	e3:SetCountLimit(1)
	e3:SetCondition(aux.PandActCon)
	e3:SetTarget(cid.destg)
	e3:SetOperation(cid.desop)
	c:RegisterEffect(e3)
end
function cid.evalue(e,re,rp)
	return re:IsActiveType(TYPE_TRAP) and rp~=e:GetHandlerPlayer()
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.PaCheckFilter,tp,LOCATION_SZONE,0,1,nil) and Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectTarget(tp,aux.PaCheckFilter,tp,LOCATION_SZONE,0,1,1,nil)
	if #g1<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	if #g2<=0 then return end
	g2:Merge(g1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,#g2,0,0)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.Destroy(g,POS_FACEUP,REASON_EFFECT)
	end
end
