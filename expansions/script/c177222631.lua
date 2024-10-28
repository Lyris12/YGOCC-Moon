--Bigbang Galactic Serpent
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.TRUE,2,s.matcheck)
	--Gains 300 ATK/DEF for each monster with different Vibes on the field, except "Bigbang Galactic Serpent".
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
	--If this card is Bigbang Summoned: You can excavate cards from the top of your Deck equal to the number of Bigbang Materials used for this card's Bigbang Summon, 
	--and if you do, you can destroy 1 excavated card, also shuffle the rest back into your Deck.
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,{id,0})
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.matcheck(g,lc)
	return g:GetClassCount(Card.GetVibe)==g:GetCount()
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(s.bfilter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,nil)
	return g:GetClassCount(Card.GetVibe)*300
end
function s.bfilter(c)
	return c:IsFaceup() and c:HasVibe() and c:GetOriginalCode()~=id
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_BIGBANG)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ddes=e:GetHandler():GetMaterialCount()
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=ddes end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ddes=e:GetHandler():GetMaterialCount()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.ConfirmDecktop(p,ddes)
	local g=Duel.GetDecktopGroup(p,ddes)
	if g:GetCount()>0 and g:IsExists(aux.TRUE,1,nil) and Duel.SelectYesNo(p,925) then
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_DESTROY)
		local sg=g:FilterSelect(p,aux.TRUE,1,1,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
	Duel.ShuffleDeck(p)
end