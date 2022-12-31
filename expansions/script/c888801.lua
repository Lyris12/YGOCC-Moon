--Abyssal Fireshard
local m=888801
local cm=_G["c"..m]
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,m)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetOperation(cm.damop)
	c:RegisterEffect(e3)
end
function cm.filter(c)
	return c:IsCode(88810101) and c:IsAbleToGrave()
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler() 
	local rc=re:GetHandler() 
	if c:GetFlagEffect(m)==0 and rc:IsSetCard(0xffc) 
		then c:RegisterFlagEffect(m,RESET_EVENT+RESET_CHAIN,0,1) 
	end 
end

function cm.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffect(m)~=0
end

function cm.damop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(1)==0 then return end
	if not re:GetHandler():IsSetCard(0xffc) then return end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,nil,LOCATION_MZONE,nil)
	local prea=g:GetSum(Card.GetAttack)
	for tc in aux.Next(g) do
		local ATK=Effect.CreateEffect(e:GetHandler())
		ATK:SetType(EFFECT_TYPE_SINGLE)
		ATK:SetCode(EFFECT_UPDATE_ATTACK)
		ATK:SetValue(-100)
		ATK:SetReset(RESET_EVENT+RESETS_STANDARD) 
		tc:RegisterEffect(ATK)
	end
	local posa=g:GetSum(Card.GetAttack)
	local ct=prea-posa
	if ct>0 then Duel.SetLP(1-tp,Duel.GetLP(1-tp)-math.floor(ct/2)) end
end
