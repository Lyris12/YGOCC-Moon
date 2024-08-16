--Library for functions reserved to YGOCC archetypes

GLITCHYLIB_YGOCC_ARCHETYPES_LOADED = true

YGOCC={}

--SCELUSPECTER
----During the Main Phase, if this card is in your hand (Quick Effect): You can banish 1 "Sceluspecter" monster from your GY; 
----equip this card to 1 monster your opponent controls. Also, the equipped monster becomes a DARK Fiend monster.
function YGOCC.RegisterSceluspecterEquip(c,id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetFunctions(
		aux.MainPhaseCond(),
		aux.BanishCost(aux.MonsterFilter(Card.IsSetCard,ARCHE_SCELUSPECTER),LOCATION_GRAVE),
		YGOCC.SceluspecterEquipTarget,
		YGOCC.SceluspecterEquipOperation
	)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetValue(RACE_FIEND)
	c:RegisterEffect(e3)
	return e1,e2,e3
end

function YGOCC.SceluspecterEquipTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExists(false,Card.IsCanBeEquippedWith,tp,0,LOCATION_MZONE,1,nil,e:GetHandler(),e,tp,REASON_EFFECT)
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,1-tp,LOCATION_MZONE)
end
function YGOCC.SceluspecterEquipOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then
		Duel.SendtoGrave(c,REASON_RULE,PLAYER_NONE)
	end
	local g=Duel.Select(HINTMSG_EQUIP,false,tp,Card.IsCanBeEquippedWith,tp,0,LOCATION_MZONE,1,1,nil,c,e,tp,REASON_EFFECT)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Duel.EquipToOtherCardAndRegisterLimit(e,tp,c,tc,true)
	end
end
