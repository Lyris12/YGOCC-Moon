--[[
Skyvoid Ranger, Espada
Esploratrice Cielovuoto, Espada
Card Author: Kinny
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--bigbang
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.TRUE,2,2,s.gcheck)
	c:EnableReviveLimit()
	--[[If this card, or another Extra Deck Monster(s), is Special Summoned: You can have this card lose 1 Attribute, then target 1 monster you control;
	equip to that target, from your Deck or GY, 1 Equip Spell that mentions it.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(nil,s.eqcost,s.eqtg,s.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.eqcon)
	c:RegisterEffect(e2)
	--[[When your opponent activates a monster effect (Quick Effect): You can banish 1 Equip Card you control equipped to a monster with the same Attribute as that monster,
	then target 1 card in your GY; add it to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetFunctions(s.discon,s.discost,s.distg,s.disop)
	c:RegisterEffect(e3)
end
function s.gcheck(mg,bc,tp)
	return mg:GetClassCount(Card.GetVibe)==1
end

--E1
function s.egfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EXTRA)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(s.egfilter,1,nil)
end
function s.filter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,c,tp)
end
function s.eqfilter(c,ec,tp)
	if not (c:IsSpell(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()) then return false end
	local codes={ec:GetCode()}
	for _,code in ipairs(codes) do
		if aux.IsCodeListed(c,code) then
			return true
		end
	end
	return false
end
function s.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local att=c:GetAttribute()
	if chk==0 then
		return att>0
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local ac=Duel.AnnounceAttribute(tp,1,att)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_REMOVE_ATTRIBUTE)
	e1:SetValue(ac)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1,true)
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp)
	end
	local g=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsControler(tp) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tc,tp)
		local eqc=g:GetFirst()
		if eqc then
			Duel.Equip(tp,eqc,tc)
		end
	end
end

--E3
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.cfilter(c,att)
	if not c:IsAbleToRemoveAsCost() then return false end
	local ec=c:GetEquipTarget()
	return ec and ec:IsAttribute(att)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local ch=chk==0 and Duel.GetCurrentChain() or Duel.GetCurrentChain()-1
	local att=rc:IsRelateToChain(ch) and rc:GetAttribute() or Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_ATTRIBUTE)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil,att)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,nil,att)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end