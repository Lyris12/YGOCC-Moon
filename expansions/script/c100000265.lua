--[[
Sceluspecter Revenge Phantom
Scelleraspettro Spirito della Vendetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

if not GLITCHYLIB_YGOCC_ARCHETYPES_LOADED then
	Duel.LoadScript("glitchylib_ygocc_archetypes.lua")
end

local s,id=GetID()
function s.initial_effect(c)
	--[[During the Main Phase (Quick Effect): You can Tribute 2 monsters on either field that have "Sceluspecter" monsters you own equipped to them; Special Summon this card from your hand or GY.]]
	aux.EnableGlobalEffectTributeOppoCost()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		aux.MainPhaseCond(),
		aux.TributeGlitchyCost(s.cfilter,2,2,nil,false,true,aux.TRUE,0,LOCATION_MZONE,nil,nil,nil,nil,aux.ChkfMMZRel(),true),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[If this card is banished from the GY: You can target as many other of your face-up banished "Sceluspecter" monsters as possible with different original names from each other and this card; 
	shuffle this card and those targets into the Deck, and if you do, inflict 400 damage to your opponent for each card shuffled into the Deck this way]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TODECK|CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_REMOVE)
	e2:HOPT()
	e2:SetFunctions(
		s.tdcon,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
	--[[Gains 800 ATK for each of your banished "Sceluspecter" monsters.]]
	c:UpdateATK(aux.ForEach(s.tdfilterchk,LOCATION_REMOVED,0,nil,800))
end

--E1
function s.cfilter(c,_,tp)
	local g=c:GetEquipGroup()
	return g and g:IsExists(s.eqcfilter,1,nil,tp)
end
function s.eqcfilter(c,tp)
	return c:IsFaceup() and c:IsMonsterCard() and c:IsSetCard(ARCHE_SCELUSCEPTER) and c:IsOwner(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (e:IsCostChecked() or Duel.GetMZoneCount(tp)>0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E2
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.tdfilter(c,e)
	return c:IsFaceup() and c:IsMonster() and not c:IsCode(id) and c:IsSetCard(ARCHE_SCELUSCEPTER) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
function s.tdfilterchk(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(ARCHE_SCELUSCEPTER)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and chkc~=c and s.tdfilter(chkc) end
	local g=Duel.Group(s.tdfilter,tp,LOCATION_REMOVED,0,c,e)
	if chk==0 then
		return c:IsAbleToDeck() and #g>0
	end
	local ct=g:GetClassCount(Card.GetCode)
	local tg=aux.SelectUnselectGroup(g,e,tp,ct,ct,aux.dncheckbrk,1,tp,HINTMSG_TODECK)
	Duel.SetTargetCard(tg)
	Duel.SetCardOperationInfo(tg+c,CATEGORY_TODECK)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,(#tg+1)*400)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetTargetCards():Filter(s.tdfilterchk,nil)
	if c:IsRelateToChain() then
		g:AddCard(c)
	end
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 then
		local ct=Duel.GetGroupOperatedByThisEffect(e):GetCount()
		if ct>0 then
			Duel.Damage(1-tp,ct*400,REASON_EFFECT)
		end
	end
end